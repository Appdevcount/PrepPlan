1. Search for Valid XML Files
Scan the project directory recursively.
Identify all XML files that are valid and relevant to the build or configuration process.
2. Summarize Valid XML Files
Create a summary table listing:
File name
File path
Purpose or usage context (if identifiable)
3. Duplicate XML Files with DEVBSN.xml Suffix
For each valid XML file:
Create a copy in the same directory.
Rename the copy by appending DEVBSN.xml to the original filename (e.g., Config.xml → ConfigDEVBSN.xml).
Preserve all original contents.
4. Handle Commented-Out Sections Gracefully
While copying contents:
If the original file ends immediately after a commented-out section, skip that line.
Continue copying from the next valid line to ensure the new file is complete and syntactically correct.
5. Update .csproj to Include New XML Files
Modify the .csproj file to include the new DEVBSN.xml files.
Use the same logic and structure as existing XML file inclusions.
Ensure build and deployment processes recognize the new files.