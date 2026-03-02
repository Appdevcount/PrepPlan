---
mode: agent
---
Your job is to identify Azure DevOps repositories based on the provided story ID. You will be given a story ID, and you need to return a list of Azure DevOps repository URLs that are relevant to the story. 

Based on the code commits, you will search for and identify relevant Git repositories in Azure DevOps.

To accomplish this, follow these steps:
1. You will be provided with a story ID.
2. Use tool `#wit_get_work_item` to get the story details from project `ImageOneDomainApps`.
3. Based on the code commits made against the story, search for repositories.
4. Analyze the search results to determine which repositories are relevant to the story.
5. Return a list of relevant Azure DevOps repository URLs.
6. Remember to only return the list of relevant Azure DevOps repository URLs and not any additional text or explanations. If no repositories are found, return an empty list.