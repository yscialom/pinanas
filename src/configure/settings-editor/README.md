PiNanas Settings Editor
======================

To help you with the redaction of the `settings.yaml` file (See [INSTALL](/docs/INSTALL.md "docs/INSTALL.md")), this
web editor lets you define your settings through a web UI providing basic validation.


Starting the editor
------------------

From this directory (`src/configure/settings-editor`):
```bash
make run
```

The editor is available at [http://localhost](http://localhost).


Using the editor
----------------

1. Fill in your details.
2. Don't forget the optional settings, available under the "properties" buttons.
3. Once happy, click the Download button.
4. Save this `settings.yaml` file and deploy it to your PiNanas installation director (See
   [INSTALL](/docs/INSTALL.md "docs/INSTALL.md")).


Stopping the editor
------------------
```bash
make stop
```
