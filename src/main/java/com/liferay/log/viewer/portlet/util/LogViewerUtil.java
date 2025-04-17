package com.liferay.log.viewer.portlet.util;

import com.liferay.portal.kernel.log.Log;
import com.liferay.portal.kernel.log.LogFactoryUtil;
import com.liferay.portal.kernel.util.PropsUtil;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;
import java.util.regex.Pattern;

/**
 * @author Asif Ahmad Shah
 */
public class LogViewerUtil {
    private static final Log _log = LogFactoryUtil.getLog(LogViewerUtil.class);

    public static String getLogBasePath(String logType) {
        String basePath;
        if ("catalina".equals(logType)) {
            String liferayHome = PropsUtil.get("liferay.home");
            File liferayHomeDir = new File(liferayHome);
            File[] tomcatDirs = liferayHomeDir.listFiles((dir, name) -> name.startsWith("tomcat-"));
            if (tomcatDirs != null && tomcatDirs.length > 0) {
                // Sort tomcat directories to get the latest version
                File latestTomcatDir = tomcatDirs[0];
                for (File dir : tomcatDirs) {
                    if (dir.lastModified() > latestTomcatDir.lastModified()) {
                        latestTomcatDir = dir;
                    }
                }
                basePath = latestTomcatDir.getAbsolutePath() + "/logs";
            } else {
                basePath = liferayHome + "/tomcat/logs";
            }
        } else {
            basePath = PropsUtil.get("liferay.home") + "/logs";
        }
        return basePath;
    }

    public static String getLatestLogFile(String basePath, String prefix) {
        File logDir = new File(basePath);
        File[] logFiles = logDir.listFiles((dir, name) -> name.startsWith(prefix) && name.endsWith(".log"));

        if (logFiles != null && logFiles.length > 0) {
            File latestFile = logFiles[0];
            for (File file : logFiles) {
                if (file.lastModified() > latestFile.lastModified()) {
                    latestFile = file;
                }
            }
            return latestFile.getAbsolutePath();
        }
        return null;
    }

    public static String getLogFileForDate(String basePath, String prefix, String date) {
        File logDir = new File(basePath);
        String expectedFileName = prefix + date + ".log";
        
        _log.debug("Looking for log file: " + expectedFileName + " in directory: " + basePath);
        
        // First try to find the exact date-specific log file
        File dateSpecificFile = new File(logDir, expectedFileName);
        if (dateSpecificFile.exists()) {
            _log.debug("Found date-specific log file: " + dateSpecificFile.getAbsolutePath());
            return dateSpecificFile.getAbsolutePath();
        }
        
        // If not found, check if it's in the default log file
        File defaultFile = new File(logDir, prefix.endsWith(".") ? 
            prefix.substring(0, prefix.length() - 1) + ".out" : prefix + ".out");
        if (defaultFile.exists()) {
            _log.debug("Using default log file: " + defaultFile.getAbsolutePath());
            return defaultFile.getAbsolutePath();
        }
        
        // If still not found, try the .log extension
        defaultFile = new File(logDir, prefix.endsWith(".") ? 
            prefix.substring(0, prefix.length() - 1) + ".log" : prefix + ".log");
        if (defaultFile.exists()) {
            _log.debug("Using default .log file: " + defaultFile.getAbsolutePath());
            return defaultFile.getAbsolutePath();
        }
        
        _log.error("No log file found for date: " + date + " with prefix: " + prefix);
        return null;
    }

    public static Set<String> getAvailableLogDates(String basePath, String prefix) {
        Set<String> dates = new HashSet<>();
        File logDir = new File(basePath);
        
        _log.info("Looking for log files in: " + basePath);
        _log.info("Using prefix: " + prefix);
        
        // List all files in the directory for debugging
        File[] allFiles = logDir.listFiles();
        if (allFiles != null) {
            for (File file : allFiles) {
                _log.info("Found file: " + file.getName());
            }
        }
        
        // Look for log files with date in the name (catalina.YYYY-MM-DD.log)
        File[] logFiles = logDir.listFiles((dir, name) -> {
            if (prefix.equals("catalina.")) {
                return name.matches("catalina\\.\\d{4}-\\d{2}-\\d{2}\\.log");
            } else if (prefix.equals("liferay.")) {
                return name.matches("liferay\\.\\d{4}-\\d{2}-\\d{2}\\.log");
            }
            return false;
        });
        
        if (logFiles != null) {
            _log.info("Found " + logFiles.length + " matching log files");
            for (File file : logFiles) {
                _log.info("Processing log file: " + file.getName());
                
                // Extract date from filename (catalina.YYYY-MM-DD.log)
                String fileName = file.getName();
                String dateStr = fileName.replaceAll(".*?(\\d{4}-\\d{2}-\\d{2}).*", "$1");
                
                dates.add(dateStr);
                _log.info("Added date: " + dateStr);
            }
        } else {
            _log.error("No log files found in directory: " + basePath);
        }

        return dates;
    }

    public static List<String> getLogsByDate(File logFile, String dateStr, String fromTimeStr, String toTimeStr) {
        List<String> logs = new ArrayList<>();
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
        Date fromDate = null;
        Date toDate = null;

        try {
            // Ensure time strings are in proper format
            if (!fromTimeStr.matches("^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$")) {
                _log.error("Invalid from time format: " + fromTimeStr);
                return logs;
            }
            if (!toTimeStr.matches("^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$")) {
                _log.error("Invalid to time format: " + toTimeStr);
                return logs;
            }

            // Append milliseconds if not provided
            fromTimeStr += ".000";
            toTimeStr += ".000";
            
            fromDate = dateFormat.parse(dateStr + " " + fromTimeStr);
            toDate = dateFormat.parse(dateStr + " " + toTimeStr);
            
            _log.debug("Searching logs from: " + dateFormat.format(fromDate) + " to: " + dateFormat.format(toDate));
            
            if (fromDate.after(toDate)) {
                _log.error("From time is after To time");
                return logs;
            }
        } catch (ParseException e) {
            _log.error("Error parsing date: " + e.getMessage(), e);
            return logs;
        }

        try (RandomAccessFile randomAccessFile = new RandomAccessFile(logFile, "r")) {
            String line;
            StringBuilder currentEntry = new StringBuilder();
            boolean withinTimeRange = false;
            Date lastLogDate = null;

            while ((line = randomAccessFile.readLine()) != null) {
                if (line.length() > 0) {
                    // Try to parse the date from the log line (format: "2025-04-15 10:20:55.040")
                    try {
                        // Check if line starts with a timestamp
                        if (line.matches("^\\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}\\.\\d{3}.*")) {
                            // If we have a previous entry, add it to logs if it's within range
                            if (currentEntry.length() > 0 && withinTimeRange) {
                                logs.add(currentEntry.toString());
                            }
                            
                            // Start new entry
                            currentEntry = new StringBuilder(line);
                            
                            // Extract the timestamp part (first 23 characters: "2025-04-15 10:20:55.040")
                            String logDateStr = line.substring(0, 23);
                            lastLogDate = dateFormat.parse(logDateStr);
                            
                            // Check if this log entry is within our time range
                            withinTimeRange = (lastLogDate.after(fromDate) || lastLogDate.equals(fromDate)) && 
                                            (lastLogDate.before(toDate) || lastLogDate.equals(toDate));
                            
                            if (lastLogDate.after(toDate)) {
                                // We've passed our time range, no need to continue
                                break;
                            }
                        } else {
                            // This is a continuation of the previous log entry
                            if (currentEntry.length() > 0) {
                                currentEntry.append("\n").append(line);
                            }
                        }
                    } catch (Exception e) {
                        // If parsing fails, treat as continuation of previous entry
                        if (currentEntry.length() > 0) {
                            currentEntry.append("\n").append(line);
                        }
                    }
                }
            }
            
            // Add the last entry if it's within range
            if (currentEntry.length() > 0 && withinTimeRange) {
                logs.add(currentEntry.toString());
            }
        } catch (IOException e) {
            _log.error("Error reading log file: " + e.getMessage(), e);
        }

        _log.debug("Found " + logs.size() + " log entries between the specified times");
        return logs;
    }
} 