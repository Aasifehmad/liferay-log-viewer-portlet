package com.liferay.log.viewer.portlet.commands;

import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.log.viewer.portlet.constants.LogViewerPortletKeys;
import com.liferay.log.viewer.portlet.util.LogViewerUtil;
import java.io.File;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.RandomAccessFile;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.TimeUnit;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;

/**
 * @author Asif Ahmad Shah
 */
@Component(
	property = {
		"javax.portlet.name=" + LogViewerPortletKeys.LOGVIEWER,
		"mvc.command.name=/log_viewer/get_logs"
	},
	service = MVCResourceCommand.class
)
public class LogViewerMVCResourceCommand implements MVCResourceCommand {

	private static final Log _log = LogFactoryUtil.getLog(LogViewerMVCResourceCommand.class);
	private static final ConcurrentHashMap<String, FilePosition> filePositions = new ConcurrentHashMap<>();
	private static final int BUFFER_SIZE = 8192;
	private static final long CACHE_TIMEOUT = TimeUnit.MINUTES.toMillis(5);

	private static class FilePosition {
		private long position;
		private long lastAccess;

		FilePosition(long position) {
			this.position = position;
			this.lastAccess = System.currentTimeMillis();
		}

		void updateAccess() {
			this.lastAccess = System.currentTimeMillis();
		}

		boolean isExpired() {
			return System.currentTimeMillis() - lastAccess > CACHE_TIMEOUT;
		}
	}

	@Override
	public boolean serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
		String portletName = LogViewerPortletKeys.LOGVIEWER;
		String logType = ParamUtil.getString(resourceRequest, portletName + "_logType");
		if (logType == null || logType.isEmpty()) {
			logType = ParamUtil.getString(resourceRequest, "logType");
		}

		cleanupExpiredPositions();

		String basePath = LogViewerUtil.getLogBasePath(logType);
		String logPath = LogViewerUtil.getLatestLogFile(basePath, "catalina".equals(logType) ? "catalina." : "liferay.");
		if (logPath == null) {
			logPath = basePath + "/" + ("catalina".equals(logType) ? "catalina.out" : "liferay.log");
		}

		File logFile = new File(logPath);
		List<String> logs = new ArrayList<>();

		if (logFile.exists()) {
			try {
				logs = readNewLogs(logFile, logType);
			} catch (IOException e) {
				_log.error("Error reading log file: " + e.getMessage(), e);
			}
		} else {
			_log.error("Log file does not exist: " + logFile.getAbsolutePath());
		}

		try {
			writeResponse(resourceResponse, logs);
			return true;
		} catch (IOException e) {
			_log.error("Error writing response: " + e.getMessage(), e);
			return false;
		}
	}

	private List<String> readNewLogs(File logFile, String logType) throws IOException {
		List<String> logs = new ArrayList<>();
		String key = logFile.getAbsolutePath();
		FilePosition filePosition = filePositions.computeIfAbsent(key, 
			k -> new FilePosition(logFile.length()));

		try (RandomAccessFile randomAccessFile = new RandomAccessFile(logFile, "r")) {
			// Handle file rotation
			if (randomAccessFile.length() < filePosition.position) {
				filePosition.position = 0;
			}

			// Use buffered reading for better performance
			byte[] buffer = new byte[BUFFER_SIZE];
			randomAccessFile.seek(filePosition.position);

			int bytesRead;
			StringBuilder currentLine = new StringBuilder();
			
			while ((bytesRead = randomAccessFile.read(buffer)) != -1) {
				for (int i = 0; i < bytesRead; i++) {
					char c = (char) buffer[i];
					if (c == '\n') {
						String line = currentLine.toString().trim();
						if (!line.isEmpty()) {
							logs.add(line);
						}
						currentLine.setLength(0);
					} else {
						currentLine.append(c);
					}
				}
			}

			// Add the last line if it doesn't end with a newline
			if (currentLine.length() > 0) {
				logs.add(currentLine.toString().trim());
			}

			filePosition.position = randomAccessFile.getFilePointer();
			filePosition.updateAccess();
		}

		return logs;
	}

	private void writeResponse(ResourceResponse resourceResponse, List<String> logs) throws IOException {
		JSONObject jsonObject = JSONFactoryUtil.createJSONObject();
		jsonObject.put("logs", logs);
		resourceResponse.setContentType("application/json");

		try (PrintWriter writer = resourceResponse.getWriter()) {
			writer.write(jsonObject.toString());
			writer.flush();
		}
	}

	private void cleanupExpiredPositions() {
		filePositions.entrySet().removeIf(entry -> entry.getValue().isExpired());
	}
}