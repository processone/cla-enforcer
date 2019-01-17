1. Install Docusign CLA manager on your project:
https://github.com/apps/docusign-cla-manager/
2. Make p1bot a member of the project
2. Enable for a given project:
```
heroku run rake cla:enforce[mremond/test-repos]
```
3. Link to generate update Github personal token for bot. You can generate token with following rights: admin:repo_hook, read:user, repo
https://github.com/settings/tokens
4. In case of update redeploy on Heroku
```
git push heroku master
```
