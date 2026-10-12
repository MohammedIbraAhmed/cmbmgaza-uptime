# CMBM Gaza uptime

Checks the CMBM Gaza services every 10 minutes from outside their server (GitHub's machines),
so an alert still goes out when the server itself is down.

| Check | What it looks at |
|---|---|
| Website opens | https://cmbmgaza.org/ answers |
| Website database | https://cmbmgaza.org/healthz?deep=1 reports the database is reachable |
| Activities app | https://app.cmbmgaza.org/api/health reports `ok` |
| Activities list the website shows | https://app.cmbmgaza.org/api/public/activities answers |
| Mail server | mx.cmbmgaza.org:465 greets like a mail server |
| Certificates | cmbmgaza.org, app.cmbmgaza.org and mx.cmbmgaza.org have 14+ days left |

**When something fails** (twice, 20 seconds apart) an issue labelled `down` is opened and GitHub
emails the repository owner. While the problem lasts the issue is only updated (with a comment if
another check starts failing). When everything works again it comments and closes the issue, which
sends a second email.

**To test the email:** Actions › Uptime › Run workflow › tick "Add a fake failure". Run it again
without the tick to close the test issue.

**To change a check:** edit `check.sh`. Only public addresses are checked; there are no secrets here.
