1. Install Docusign CLA manager on your project:
https://github.com/apps/docusign-cla-manager/
2. Make p1bot a member of the project (admin access). Write is needed to read list of contributors. Admin is needed to create webhooks (can be just write after).
2. Enable for a given project:
```
heroku run rake cla:enforce[mremond/test-repos]
```
2. Adjust label description:
Contributor needs to sign Contribution License Agreement
3. Link to generate update Github personal token for bot. You can generate token with following rights: admin:repo_hook, read:user, repo
https://github.com/settings/tokens
4. In case of update redeploy on Heroku
```
git push heroku master
```

# Manually post request as bot

```
heroku run rake cla:checkpr[https://github.com/mremond/test-repos/pull/6,mremondp1]
```

# Misc

To schedule / unschedule a backup:
```
heroku pg:backups:schedule --at '02:00 Europe/Paris' --app cla-enforcer
heroku pg:backups:unschedule --app cla-enforcer 
```

Manual backup and download:
```
heroku pg:backups:capture
heroku pg:backups:url b001 --app cla-enforcer
```
