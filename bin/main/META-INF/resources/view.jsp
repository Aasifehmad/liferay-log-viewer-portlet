<%@ include file="/init.jsp"%>
<%@ page import="java.util.List"%>
<%@ taglib uri="http://liferay.com/tld/clay" prefix="clay" %>

<portlet:resourceURL var="refreshLogsURL" id="/log_viewer/get_logs" />
<portlet:resourceURL var="getDatesURL" id="/log_viewer/get_dates" />
<portlet:resourceURL var="getLogsByDateURL" id="/log_viewer/get_logs_by_date" />

<div class="container-fluid log-viewer-container" id="<portlet:namespace />logViewer">
	<div class="row">
		<div class="col-md-12">
			<div class="card">
				<div class="card-header">
					<h3 class="card-title">Liferay Server Log Viewer</h3>
					<div class="card-tools">
						<div class="btn-group">
							<select id="<portlet:namespace />logType" class="form-control"
								onchange="<portlet:namespace />onLogTypeChange();">
								<option value="" selected disabled>Select Log Type</option>
								<option value="liferay">Liferay Log</option>
								<option value="catalina">Catalina Log</option>
							</select>
							<button id="<portlet:namespace />toggleButton"
								class="btn btn-success"
								onclick="<portlet:namespace />toggleLogs();" disabled>
								<div class="btn-content">
									<clay:icon symbol="play" />
									<span>Start</span>
								</div>
							</button>
							<button id="<portlet:namespace />clearButton"
								class="btn btn-warning"
								onclick="<portlet:namespace />clearLogs();">
								<div class="btn-content">
									<clay:icon symbol="trash" />
									<span>Clear</span>
								</div>
							</button>
							<button id="<portlet:namespace />downloadButton"
								class="btn btn-info"
								onclick="<portlet:namespace />downloadLogs();">
								<div class="btn-content">
									<clay:icon symbol="download" />
									<span>Download</span>
								</div>
							</button>
							<button id="<portlet:namespace />viewErrorReportButton"
								class="btn btn-danger"
								onclick="<portlet:namespace />generateErrorReport();">
								<div class="btn-content">
									<clay:icon symbol="exclamation-circle" />
									<span>View Error Report</span>
								</div>
							</button>
							<div class="dropdown">
								<button id="<portlet:namespace />viewByDateButton"
									class="btn btn-primary dropdown-toggle"
									type="button"
									data-toggle="dropdown"
									aria-haspopup="true"
									aria-expanded="false">
									<div class="btn-content">
										<clay:icon symbol="calendar" />
										<span>View by Date</span>
									</div>
								</button>
								<div class="dropdown-menu dropdown-menu-right p-3" style="width: 300px;"
									onclick="event.stopPropagation();">
									<div class="form-group">
										<label for="<portlet:namespace />logDate">Date:</label>
										<select id="<portlet:namespace />logDate" class="form-control">
											<option value="" selected disabled>Select Date</option>
										</select>
									</div>
									<div class="form-group">
										<label for="<portlet:namespace />fromTime">From Time:</label>
										<input type="time" id="<portlet:namespace />fromTime"
											class="form-control" step="1" value="00:00:00"
											pattern="[0-9]{2}:[0-9]{2}:[0-9]{2}"
											onchange="<portlet:namespace />validateTime(this);">
									</div>
									<div class="form-group">
										<label for="<portlet:namespace />toTime">To Time:</label>
										<input type="time" id="<portlet:namespace />toTime"
											class="form-control" step="1" value="23:59:59"
											pattern="[0-9]{2}:[0-9]{2}:[0-9]{2}"
											onchange="<portlet:namespace />validateTime(this);">
									</div>
									<div class="dropdown-divider"></div>
									<button type="button" class="btn btn-primary btn-block"
										onclick="<portlet:namespace />fetchLogsByDate();">
										<div class="btn-content">
											<clay:icon symbol="view" />
											<span>View Logs</span>
										</div>
									</button>
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="card-body">
					<pre id="<portlet:namespace />logContent" class="log-content"></pre>
				</div>
			</div>
		</div>
	</div>
</div>

<!-- Error Report Modal -->
<div class="modal fade" id="<portlet:namespace />errorReportModal"
	tabindex="-1" role="dialog" aria-labelledby="errorReportModalLabel"
	aria-hidden="true">
	<div class="modal-dialog modal-lg" role="document">
		<div class="modal-content">
			<div class="modal-header">
				<h5 class="modal-title" id="errorReportModalLabel">Error Report</h5>
				<button type="button" class="close" data-dismiss="modal"
					aria-label="Close">
					<span aria-hidden="true">&times;</span>
				</button>
			</div>
			<div class="modal-body">
				<div class="error-report-content">
					<pre class="log-pre" id="<portlet:namespace />errorReportContent"></pre>
				</div>
			</div>
			<div class="modal-footer">
				<button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
				<button type="button" class="btn btn-primary"
					onclick="<portlet:namespace />downloadErrorReport();">
					<div class="btn-content">
						<clay:icon symbol="download" />
						<span>Download Report</span>
					</div>
				</button>
			</div>
		</div>
	</div>
</div>

<style>
.log-viewer-container {
	height: 100%;
	display: flex;
	flex-direction: column;
}

.card {
	flex: 1;
	display: flex;
	flex-direction: column;
	margin-bottom: 20px;
}

.card-body {
	flex: 1;
	display: flex;
	flex-direction: column;
	padding: 0;
}

.log-content {
	height: 500px;
	overflow-y: auto;
	overflow-x: hidden;
	background-color: #f8f9fa;
	padding: 10px;
	border: 1px solid #dee2e6;
	border-radius: 4px;
	font-family: 'Courier New', Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	white-space: pre-wrap;
	word-wrap: break-word;
	word-break: break-all;
	max-width: 100%;
}

.card-header {
	display: flex;
	justify-content: space-between;
	align-items: center;
	padding: 1rem;
	background-color: #fff;
	border-bottom: 1px solid #dee2e6;
}

.card-tools {
	display: flex;
	gap: 0.5rem;
}

.btn-group {
	display: flex;
	gap: 0.5rem;
	align-items: center;
}

.form-control {
	min-width: 150px;
}

.error-keyword {
	color: #dc3545;
	font-weight: bold;
}

.error-line {
	padding: 15px;
	background-color: #f8f9fa;
	border: 1px solid #dee2e6;
	border-radius: 4px;
	margin-bottom: 5px;
	display: flex;
	flex-wrap: wrap;
	word-break: break-all;
	max-width: 100%;
}

.line-number {
	flex: 0 0 40px;
	color: #6c757d;
	font-weight: bold;
}

.line-content {
	flex: 1;
	min-width: 200px;
	white-space: pre-wrap;
	word-wrap: break-word;
	word-break: break-all;
	max-width: 100%;
}

.error-separator {
	height: 30px;
	margin: 15px 0;
	border: none;
}

.error-summary {
	background-color: #e9ecef;
	padding: 10px;
	border-radius: 4px;
	margin-bottom: 20px;
	font-weight: bold;
}

.loading {
	position: relative;
	pointer-events: none;
}

.loading:after {
	content: '';
	position: absolute;
	width: 16px;
	height: 16px;
	top: 50%;
	left: 50%;
	margin-top: -8px;
	margin-left: -8px;
	border: 2px solid rgba(255, 255, 255, 0.3);
	border-radius: 50%;
	border-top-color: #fff;
	animation: spin 0.8s linear infinite;
}

@keyframes spin {
	to {transform: rotate(360deg);}
}

.btn-content {
	display: inline-flex;
	align-items: center;
	gap: 0.5rem;
}

.dropdown-menu {
	max-height: 500px;
	overflow-y: auto;
}

.dropdown-menu label {
	font-size: 14px;
	margin-bottom: 0.25rem;
}

.dropdown-menu .form-group {
	margin-bottom: 1rem;
}

.dropdown-menu input[type="time"],
.dropdown-menu select {
	font-size: 14px;
}

.error-report-content {
	max-height: 70vh;
	overflow: hidden;
	display: flex;
	flex-direction: column;
}

.error-summary {
	background-color: #e9ecef;
	padding: 10px;
	border-radius: 4px;
	margin-bottom: 20px;
	font-weight: bold;
	flex-shrink: 0;
}

.error-lines-container {
	flex: 1;
	overflow-y: auto;
	padding-right: 10px;
}

.error-line {
	padding: 15px;
	background-color: #f8f9fa;
	border: 1px solid #dee2e6;
	border-radius: 4px;
	margin-bottom: 5px;
	display: flex;
	flex-wrap: wrap;
	word-break: break-word;
}
</style>

<aui:script>
	var <portlet:namespace />isAutoRefreshing = false;
	var <portlet:namespace />refreshInterval;
	var <portlet:namespace />errorLines = [];
	var <portlet:namespace />debounceTimer;
	const DEBOUNCE_DELAY = 300;

	function <portlet:namespace />debounce(func) {
		clearTimeout(<portlet:namespace />debounceTimer);
		<portlet:namespace />debounceTimer = setTimeout(func, DEBOUNCE_DELAY);
	}

	function <portlet:namespace />onLogTypeChange() {
		var logType = document.getElementById('<portlet:namespace />logType').value;
		var toggleButton = document.getElementById('<portlet:namespace />toggleButton');
		toggleButton.disabled = !logType;
		
		if (logType) {
			<portlet:namespace />debounce(<portlet:namespace />updateAvailableDates);
		}
	}

	function <portlet:namespace />validateTime(input) {
		var timeRegex = /^([01]?[0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9]$/;
		if (!timeRegex.test(input.value)) {
			alert('Please enter time in 24-hour format (HH:mm:ss)');
			input.value = input.value === '' ? '00:00:00' : '23:59:59';
		}
	}

	function <portlet:namespace />updateAvailableDates() {
		var logType = document.getElementById('<portlet:namespace />logType').value;
		if (!logType) return;

		AUI().use('aui-io-request', function(A) {
			A.io.request('${getDatesURL}', {
				method: 'POST',
				data: {
					'<portlet:namespace />logType': logType,
					'<portlet:namespace />_getAvailableDates': true
				},
				dataType: 'json',
				on: {
					success: function() {
						var data = this.get('responseData');
						var dateSelect = document.getElementById('<portlet:namespace />logDate');
						dateSelect.innerHTML = '<option value="" selected disabled>Select Date</option>';
						
						if (data.dates && data.dates.length > 0) {
							// Sort dates in descending order
							data.dates.sort(function(a, b) {
								return new Date(b) - new Date(a);
							});
							
							data.dates.forEach(function(date) {
								var option = document.createElement('option');
								option.value = date;
								option.textContent = date;
								dateSelect.appendChild(option);
							});
						} else {
							dateSelect.innerHTML = '<option value="" selected disabled>No dates available</option>';
						}
					},
					failure: function() {
						console.error('Failed to fetch dates');
					}
				}
			});
		});
	}

	function <portlet:namespace />fetchLogsByDate() {
		var viewLogsButton = document.querySelector('#<portlet:namespace />viewByDateButton + .dropdown-menu .btn-primary');
		viewLogsButton.classList.add('loading');
		viewLogsButton.disabled = true;

		var logType = document.getElementById('<portlet:namespace />logType').value;
		var date = document.getElementById('<portlet:namespace />logDate').value;
		var fromTime = document.getElementById('<portlet:namespace />fromTime').value;
		var toTime = document.getElementById('<portlet:namespace />toTime').value;

		if (!logType || !date || !fromTime || !toTime) {
			alert('Please fill in all fields');
			viewLogsButton.classList.remove('loading');
			viewLogsButton.disabled = false;
			return;
		}

		// Clear existing logs when fetching by date
		var logContent = document.getElementById('<portlet:namespace />logContent');
		logContent.innerHTML = '';
		<portlet:namespace />errorLines = [];

		AUI().use('aui-io-request', function(A) {
			A.io.request('${getLogsByDateURL}', {
				method: 'POST',
				data: {
					'<portlet:namespace />logType': logType,
					'<portlet:namespace />date': date,
					'<portlet:namespace />fromTime': fromTime,
					'<portlet:namespace />toTime': toTime
				},
				on: {
					success: function(event, id, obj) {
						var response = this.get('responseData');
						try {
							var jsonResponse = JSON.parse(response);
							if (jsonResponse.error) {
								alert(jsonResponse.error);
							} else {
								// Handle both string and array formats
								var logs = [];
								if (Array.isArray(jsonResponse.logs)) {
									logs = jsonResponse.logs;
								} else if (typeof jsonResponse.logs === 'string') {
									logs = jsonResponse.logs.split('\n');
								} else {
									console.error('Unexpected logs format:', jsonResponse.logs);
									alert('Unexpected logs format received');
									return;
								}

								// Filter out empty lines and process each line
								var processedLines = logs
									.filter(function(line) { return line && line.trim(); })
									.map(function(line) {
										// First escape the HTML to prevent XSS
										var escapedLine = A.Escape.html(line.trim());
										// Then apply error highlighting
										return escapedLine.replace(/(error|exception|failed|fatal|severe|warn)/gi, 
											'<span class="error-keyword">$1</span>');
									});

								// Join the lines back together and update the display
								if (processedLines.length > 0) {
									logContent.innerHTML = processedLines.join('\n');
									// Auto-scroll to top for historical logs
									logContent.scrollTop = 0;

									// Store error lines for report
									<portlet:namespace />errorLines = logs.filter(function(line) {
										return /error|exception|failed|fatal|severe|warn/i.test(line);
									});

									// Only close the dropdown after successful log fetch
									AUI.$('#<portlet:namespace />viewByDateButton').dropdown('toggle');
								} else {
									logContent.innerHTML = 'No logs found for the selected date and time range.';
								}
							}
						} catch (e) {
							console.error('Error parsing response:', e);
							console.error('Response data:', response);
							alert('Error loading logs: ' + e.message);
						} finally {
							viewLogsButton.classList.remove('loading');
							viewLogsButton.disabled = false;
						}
					},
					failure: function() {
						alert('Error loading logs');
						viewLogsButton.classList.remove('loading');
						viewLogsButton.disabled = false;
					}
				}
			});
		});
	}

	function <portlet:namespace />toggleLogs() {
		var toggleButton = document.getElementById('<portlet:namespace />toggleButton');
		var logType = document.getElementById('<portlet:namespace />logType').value;
		
		if (!logType) {
			return;
		}
		
		if (!<portlet:namespace />isAutoRefreshing) {
			// Start logs
			<portlet:namespace />isAutoRefreshing = true;
			// Clear existing logs first
			document.getElementById('<portlet:namespace />logContent').innerHTML = '';
			<portlet:namespace />errorLines = [];
			// Then start refreshing
			<portlet:namespace />refreshLogs(); // Get initial logs immediately
			<portlet:namespace />refreshInterval = setInterval(<portlet:namespace />refreshLogs, 1000);
			
			// Update button to Stop state
			toggleButton.innerHTML = '<clay:icon symbol="stop" /><span class="ml-1">Stop</span>';
			toggleButton.className = 'btn btn-danger';
		} else {
			// Stop logs
			clearInterval(<portlet:namespace />refreshInterval);
			<portlet:namespace />isAutoRefreshing = false;
			
			// Update button to Start state
			toggleButton.innerHTML = '<clay:icon symbol="play" /><span class="ml-1">Start</span>';
			toggleButton.className = 'btn btn-success';
		}
	}

	function <portlet:namespace />clearLogs() {
		var logContent = document.getElementById('<portlet:namespace />logContent');
		logContent.innerHTML = '';
		<portlet:namespace />errorLines = [];
		
		// Also clear any existing interval if it's running
		if (<portlet:namespace />isAutoRefreshing) {
			clearInterval(<portlet:namespace />refreshInterval);
			<portlet:namespace />isAutoRefreshing = false;
			
			// Update toggle button to Start state
			var toggleButton = document.getElementById('<portlet:namespace />toggleButton');
			toggleButton.innerHTML = '<clay:icon symbol="play" /><span class="ml-1">Start</span>';
			toggleButton.className = 'btn btn-success';
		}
	}

	function <portlet:namespace />refreshLogs() {
		var logType = document.getElementById('<portlet:namespace />logType').value;
		var logContent = document.getElementById('<portlet:namespace />logContent');
		
		AUI().use('aui-base', 'aui-io-request', function(A) {
			A.io.request('${refreshLogsURL}', {
				method: 'GET',
				data: {
					'<portlet:namespace />logType': logType
				},
				dataType: 'json',
				on: {
					success: function(event, id, obj) {
						var response = this.get('responseData');
						if (response && response.logs) {
							var logs = Array.isArray(response.logs) ? 
								response.logs : 
								response.logs.split('\n');

							// Filter and process logs
							var processedLogs = logs
								.filter(function(line) { return line && line.trim(); })
								.map(function(line) {
									// First escape the HTML to prevent XSS
									var escapedLine = A.Escape.html(line.trim());
									// Then apply error highlighting
									return escapedLine.replace(/(error|exception|failed|fatal|severe|warn)/gi, 
										'<span class="error-keyword">$1</span>');
								}).join('\n');
							
							// Only append new logs if there are any
							if (processedLogs) {
								if (logContent.innerHTML) {
									logContent.innerHTML += '\n' + processedLogs;
								} else {
									logContent.innerHTML = processedLogs;
								}
								
								// Store error lines for report
								var newErrorLines = logs.filter(function(line) {
									return /error|exception|failed|fatal|severe|warn/i.test(line);
								});
								<portlet:namespace />errorLines = <portlet:namespace />errorLines.concat(newErrorLines);
								
								// Auto-scroll to bottom if we're near the bottom already
								if (logContent.scrollHeight - logContent.scrollTop <= logContent.clientHeight + 50) {
									logContent.scrollTop = logContent.scrollHeight;
								}
							}
						}
					}
				}
			});
		});
	}

	function <portlet:namespace />downloadLogs() {
		var downloadButton = document.getElementById('<portlet:namespace />downloadButton');
		downloadButton.classList.add('loading');
		downloadButton.disabled = true;

		try {
			var logContent = document.getElementById('<portlet:namespace />logContent').innerText;
			var logType = document.getElementById('<portlet:namespace />logType').value;
			var blob = new Blob([logContent], {type: 'text/plain'});
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.href = url;
			a.download = logType + '_logs_' + new Date().toISOString().slice(0,10) + '.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		} finally {
			setTimeout(function() {
				downloadButton.classList.remove('loading');
				downloadButton.disabled = false;
			}, 1000);
		}
	}

	function <portlet:namespace />generateErrorReport() {
		var reportButton = document.getElementById('<portlet:namespace />viewErrorReportButton');
		reportButton.classList.add('loading');
		reportButton.disabled = true;

		AUI().use('aui-base', function(A) {
			var errorReportContent = document.getElementById('<portlet:namespace />errorReportContent');
			var errorLines = <portlet:namespace />errorLines;
			
			if (errorLines.length > 0) {
				var reportHtml = 
					'<div class="error-summary">Total Errors Found: ' + errorLines.length + '</div>' +
					'<div class="error-separator"></div>' +
					'<div class="error-lines-container">' +
					errorLines.map(function(line, index) {
						var escapedLine = A.Escape.html(line);
						var highlightedLine = escapedLine.replace(/(error|exception|failed|fatal|severe)/gi, 
							'<span class="error-keyword">$1</span>');
						return '<div class="error-line">' +
							   '<div class="line-number">#' + (index + 1) + '</div>' +
							   '<div class="line-content">' + highlightedLine + '</div>' +
							   '</div>' +
							   (index < errorLines.length - 1 ? '<div class="error-separator"></div>' : '');
					}).join('') +
					'</div>';
				
				errorReportContent.innerHTML = reportHtml;
			} else {
				errorReportContent.innerHTML = '<div class="alert alert-info">No errors found in the logs.</div>';
			}
			
			// Show the modal and remove loading state
			AUI.$('#<portlet:namespace />errorReportModal').modal('show');
			setTimeout(function() {
				reportButton.classList.remove('loading');
				reportButton.disabled = false;
			}, 500);
		});
	}

	function <portlet:namespace />downloadErrorReport() {
		var downloadButton = document.querySelector('#<portlet:namespace />errorReportModal .btn-primary');
		downloadButton.classList.add('loading');
		downloadButton.disabled = true;

		try {
			var errorContent = <portlet:namespace />errorLines.join('\n');
			var blob = new Blob([errorContent], {type: 'text/plain'});
			var url = window.URL.createObjectURL(blob);
			var a = document.createElement('a');
			a.href = url;
			a.download = 'error_report_' + new Date().toISOString().slice(0,10) + '.txt';
			document.body.appendChild(a);
			a.click();
			window.URL.revokeObjectURL(url);
			document.body.removeChild(a);
		} finally {
			setTimeout(function() {
				downloadButton.classList.remove('loading');
				downloadButton.disabled = false;
			}, 1000);
		}
	}

	AUI().ready(function() {
		// Prevent dropdown from closing when clicking inside
		AUI.$('.dropdown-menu').on('click', function(e) {
			e.stopPropagation();
		});

		// Initialize the dropdown with proper behavior
		AUI.$('#<portlet:namespace />viewByDateButton').dropdown({
			closeOnClick: false
		});
	});
</aui:script>
