
#!/usr/bin/env python3

import subprocess
import re

from ansible.module_utils.common.text.converters import to_native
from ansible.errors import AnsibleFilterError

class FilterModule:
    def filters(self):
        return {'authelia_password': self.authelia_password }

    def authelia_password(self, cleartext):
        self.__command = ['docker', 'run', '--rm', 'authelia/authelia:4', 'authelia', 'hash-password', cleartext]
        try:
            process = subprocess.run(self.__command, check=True, capture_output=True, text=True)
        except (IOError, subprocess.CalledProcessError) as e:
            raise self.__error(to_native(e))
        return self.__extract_ciphertext(process.stdout)

    def __extract_ciphertext(self, authelia_stdout):
        regex = re.compile('^Password hash: ([0-9A-Za-z,$/=+-]+)$')
        matches = regex.match(authelia_stdout)
        if not matches:
            return self.__error("Unable to extract ciphered password")
        return matches.group(1)

    def __error(self, e=None):
        redacted_command_string = ' '.join(self.__command[:-1]+['*****'])
        formatted_error_string = e.replace(self.__command[-1], '*****') if e else ""
        raise AnsibleFilterError("Error running '{}'; msg: '{}'.".format(redacted_command_string, formatted_error_string))
