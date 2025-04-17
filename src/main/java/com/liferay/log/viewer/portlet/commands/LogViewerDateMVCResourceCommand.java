package com.liferay.log.viewer.portlet.commands;

import com.liferay.log.viewer.portlet.constants.LogViewerPortletKeys;
import com.liferay.log.viewer.portlet.util.LogViewerUtil;
import com.liferay.portal.kernel.json.JSONFactoryUtil;
import com.liferay.portal.kernel.json.JSONObject;
import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.portlet.bridges.mvc.MVCResourceCommand;
import com.liferay.portal.kernel.util.ParamUtil;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Set;

import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;

import org.osgi.service.component.annotations.Component;

/**
 * @author Asif Ahmad Shah
 */
@Component(
    property = {
        "javax.portlet.name=" + LogViewerPortletKeys.LOGVIEWER,
        "mvc.command.name=/log_viewer/get_dates"
    },
    service = MVCResourceCommand.class
)
public class LogViewerDateMVCResourceCommand implements MVCResourceCommand {

    private static final Log _log = LogFactoryUtil.getLog(LogViewerDateMVCResourceCommand.class);

    @Override
    public boolean serveResource(ResourceRequest resourceRequest, ResourceResponse resourceResponse) {
        String portletName = LogViewerPortletKeys.LOGVIEWER;
        String logType = ParamUtil.getString(resourceRequest, portletName + "_logType");
        if (logType == null || logType.isEmpty()) {
            logType = ParamUtil.getString(resourceRequest, "logType");
        }

        String basePath = LogViewerUtil.getLogBasePath(logType);

        try {
            JSONObject jsonObject = JSONFactoryUtil.createJSONObject();
            Set<String> dates = LogViewerUtil.getAvailableLogDates(basePath, "catalina".equals(logType) ? "catalina." : "liferay.");
            jsonObject.put("dates", new ArrayList<>(dates));
            resourceResponse.setContentType("application/json");
            PrintWriter writer = resourceResponse.getWriter();
            writer.write(jsonObject.toString());
            writer.flush();
        } catch (IOException e) {
            _log.error("Error writing response: " + e.getMessage(), e);
        }

        return false;
    }
} 