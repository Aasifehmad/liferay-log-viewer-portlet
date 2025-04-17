# Liferay Log Viewer Portlet

A Liferay portlet for viewing and analyzing server logs with advanced features.

## Author
Asif Ahmad Shah

## Features

- Real-time log viewing
- View logs by date and time range
- Error report generation
- Log file download
- Support for both Liferay and Tomcat logs
- Responsive and user-friendly interface
- Error highlighting and filtering
- Automatic log rotation handling

## Prerequisites

- Liferay DXP/Portal 7.4+
- Java 8 or higher
- Maven 3.6 or higher

## Installation

1. Build the project:
   ```bash
   mvn clean install
   ```

2. Deploy the generated JAR file to your Liferay instance's `deploy` folder.

3. Add the portlet to any page using the "Log Viewer" widget.

## Usage

### Viewing Logs

1. Select the log type (Liferay or Catalina)
2. Click "Start" to begin viewing logs in real-time
3. Use "Clear" to reset the log view
4. Click "Stop" to pause log viewing

### Viewing Logs by Date

1. Click the "View by Date" button
2. Select a date from the dropdown
3. Set the time range
4. Click "View Logs" to see logs for the selected period

### Error Report

1. Click "View Error Report" to generate a report of all errors in the current log view
2. Use "Download Report" to save the error report

### Downloading Logs

1. Click "Download" to save the current log view to a file

## Configuration

The portlet automatically detects and uses the appropriate log directories:
- Liferay logs: `$LIFERAY_HOME/logs/`
- Tomcat logs: `$LIFERAY_HOME/tomcat-{version}/logs/`

## Technical Details

### Package Structure

```
src/main/java/com/liferay/log/viewer/portlet/
├── LogViewerPortlet.java (root package)
├── commands/
│   ├── LogViewerMVCResourceCommand.java
│   ├── LogViewerDateMVCResourceCommand.java
│   └── LogViewerDateLogsMVCResourceCommand.java
├── util/
│   └── LogViewerUtil.java
└── constants/
    └── LogViewerPortletKeys.java
```

### Key Components

- `LogViewerPortlet`: Main portlet class
- `LogViewerUtil`: Utility class for log file operations
- `LogViewerMVCResourceCommand`: Handles real-time log viewing
- `LogViewerDateMVCResourceCommand`: Manages date-based log viewing
- `LogViewerDateLogsMVCResourceCommand`: Handles log retrieval by date and time

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support, please contact the author or create an issue in the repository. 