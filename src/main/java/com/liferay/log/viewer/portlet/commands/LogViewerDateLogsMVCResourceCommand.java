package com.liferay.log.viewer.portlet.commands;

import com.liferay.log.viewer.portlet.util.LogViewerUtil;
import com.liferay.log.viewer.portlet.constants.LogViewerPortletKeys;
import com.liferay.portal.kernel.json.JSONArray;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;
import com.liferay.portal.kernel.util.Validator;

import java.io.File;
import java.io.PrintWriter;
import java.util.List;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;

/**
 * @author Asif Ahmad Shah
 */
@Component(
    immediate = true,
    property = {
        "javax.portlet.name=" + LogViewerPortletKeys.LOGVIEWER,
        "mvc.command.name=/log_viewer/get_logs_by_date"
    },
    service = MVCResourceCommand.class
)
public class LogViewerDateLogsMVCResourceCommand implements MVCResourceCommand {

    @Override
    public boolean serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
        try {
            String logType = ParamUtil.getString(resourceRequest, "logType");
            String date = ParamUtil.getString(resourceRequest, "date");
            String fromTime = ParamUtil.getString(resourceRequest, "fromTime");
            String toTime = ParamUtil.getString(resourceRequest, "toTime");

            _log.debug("Received parameters - logType: " + logType + ", date: " + date + 
                      ", fromTime: " + fromTime + ", toTime: " + toTime);

            JSONObject jsonResponse = JSONFactoryUtil.createJSONObject();

            // Validate required parameters
            if (Validator.isNull(logType) || Validator.isNull(date) || 
                Validator.isNull(fromTime) || Validator.isNull(toTime)) {
                jsonResponse.put("error", "Missing required parameters");
                _log.error("Missing required parameters");
                writeJSON(resourceResponse, jsonResponse);
                return true;
            }

            String prefix = "catalina.".equals(logType) ? "catalina." : "liferay.";
            String basePath = LogViewerUtil.getLogBasePath(logType);
            String logFilePath = LogViewerUtil.getLogFileForDate(basePath, prefix, date);

            if (logFilePath == null) {
                jsonResponse.put("error", "No log file found for the specified date");
                _log.error("No log file found for date: " + date);
                writeJSON(resourceResponse, jsonResponse);
                return true;
            }

            File logFile = new File(logFilePath);
            List<String> logs = LogViewerUtil.getLogsByDate(logFile, date, fromTime, toTime);

            JSONArray logsArray = JSONFactoryUtil.createJSONArray();
            for (String log : logs) {
                logsArray.put(log);
            }

            jsonResponse.put("logs", logsArray);
            writeJSON(resourceResponse, jsonResponse);

            return true;
        }
        catch (Exception e) {
            _log.error("Error processing request: " + e.getMessage(), e);
            return false;
        }
    }

    private void writeJSON(ResourceResponse resourceResponse, JSONObject jsonObject) {
        try {
            PrintWriter writer = resourceResponse.getWriter();
            writer.write(jsonObject.toString());
            writer.close();
        }
        catch (Exception e) {
            _log.error("Error writing JSON response: " + e.getMessage(), e);
        }
    }

    private static final Log _log = LogFactoryUtil.getLog(LogViewerDateLogsMVCResourceCommand.class);
} 