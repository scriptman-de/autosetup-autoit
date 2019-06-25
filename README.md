# AutoSetup AutoIT

Setup script for unattended software installation

## AutoSetup.ini fields description
The ``AutoSetup.ini`` file includes all parameters for the software being installed. It must be provided for each software in its own folder in the ``bin`` directory.

These fields are available for the ``AutoSetup.ini`` file

* ``clearName`` The name of the software shown in the GUI
* ``installer`` The scriptfile name to install the software (used when there more then one line of code to install the software)
* ``command`` The command line for unattended setup of the software. If this line is provided, it takes precedence over the ``installer`` script.
* ``basicSetup`` True|False if this entry is preselected in the GUI