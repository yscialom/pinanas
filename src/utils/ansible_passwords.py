#!/usr/bin/env python3

import os
import subprocess
import re
import tempfile
import shutil
import bcrypt

from ansible.module_utils.common.text.converters import to_native
from ansible.errors import AnsibleFilterError

ENCODING='utf-8'

class Authelia:
    def key(self, opt=''):
        try:
            _ = self.__run(['docker', 'run', '--rm', '-u', '{}'.format(os.getuid()), '-v', 'pinanas-config:/pinanas-config', 'authelia/authelia:4.35', 'authelia',
                'rsa', 'generate', '--dir', '/pinanas-config/keys'])
            with open('/pinanas-config/keys/key.pem') as keyfile:
                key = keyfile.read()
        finally:
            shutil.rmtree('/pinanas-config/keys')
        return self.__transform(key, opt)

    def password(self, cleartext):
        command = ['docker', 'run', '--rm', 'authelia/authelia:4.35', 'authelia', 'hash-password', '--', cleartext]
        stdout = self.__run(command)
        return self.__extract_ciphertext(command, stdout)

    def __run(self, command):
        try:
            process = subprocess.run(command, check=True, capture_output=True, text=True)
        except (IOError, subprocess.CalledProcessError) as e:
            raise self.__error(command, to_native(e))
        return process.stdout

    def __transform(self, key, opt):
        indent_match = re.search(r'indent=(\d)+', opt)
        indent = int(indent_match.group(1)) if indent_match else 0
        key_lines = key.splitlines()
        return key_lines[0] + '\n' + re.sub(r'^', ' '*indent, '\n'.join(key_lines[1:]), flags=re.MULTILINE)

    def __extract_ciphertext(self, command, authelia_stdout):
        regex = re.compile('^(Password hash|Digest): ([0-9A-Za-z,$/=+-]+)$')
        matches = regex.match(authelia_stdout)
        if not matches:
            return self.__error(command, "Unable to extract ciphered password")
        return matches.group(2)

    def __error(self, command, e=None):
        redacted_command_string = ' '.join(command[:-1]+['*****'])
        formatted_error_string = e.replace(str(command[-1]), '*****') if e else ""
        raise AnsibleFilterError("Error running '{}'; msg: '{}'.".format(redacted_command_string, formatted_error_string))


class Adguardhome:
    def password(self, cleartext):
        return bcrypt.hashpw(cleartext, bcrypt.gensalt()).decode(ENCODING)


class FilterModule:
    def password(self, Implementation):
        return lambda cleartext: Implementation().password(cleartext.encode(ENCODING))

    def key(self, Implementation):
        return lambda opt: Implementation().key(opt)

    def filters(self):
        return {
            'authelia_password': self.password(Authelia),
            'authelia_sshkey': self.key(Authelia),
            'adguardhome_password': self.password(Adguardhome)
        }
