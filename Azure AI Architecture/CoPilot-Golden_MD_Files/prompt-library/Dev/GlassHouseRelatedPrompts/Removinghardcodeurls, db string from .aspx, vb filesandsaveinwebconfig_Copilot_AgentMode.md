1.Find Hardcoded URLs:
Scan all .aspx and .vb pages in the project.
Identify and extract all hardcoded valid URLs and IPAddress.
Store the list of found URLs and IPAddress in a table (to be shared in chat).
if no hardcode value found then stop
2.Update web.config:
For each URL, add a key-value pair in the <appSettings> section of web.config.
Use a descriptive key for each URL and IPAddress .
3.Refactor .aspx Pages:
Replace each hardcoded URL and IPAddress  in the .aspx page with a reference to the corresponding key from web.config (e.g., ConfigurationManager.AppSettings["YourKey"] or  <%$ AppSettings:YourKey %> ).
4.Update Code-Behind Files:
For each .aspx.vb code-behind file, check if the necessary namespace (System.Configuration) is imported.
If not, add the import statement at the top of the file.
5.Validation:
After refactoring, scan the .aspx pages again to collect all URLs now referenced from web.config.
Store the updated list in a second table (to be shared in chat).
Compare the original and updated tables to ensure all URLs and IPAddress  have been properly updated.
Provide a message in chat indicating whether all URLs and IPAddress were updated successfully in BOLD