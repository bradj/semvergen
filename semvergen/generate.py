import re
import subprocess
import sys


def _get_latest_tag():
    out = subprocess.Popen(['git', 'describe', '--always'],
                           stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT)

    stdout, stderr = out.communicate()

    if stderr:
        print(stderr)
        sys.exit(1)

    return stdout.decode('utf-8').strip()


def version():
    version = _get_latest_tag()

    if '-' not in version:
        print(version)
        sys.exit(0)

    major_minor = re.match(r'\d+\.\d+\.', version)
    patch = re.search(r'-(\d+)-', version)

    if not patch or not major_minor:
        print('Version is wrong.', version)
        sys.exit(1)

    print('%s%s' % (major_minor.group(), patch.group(1)))
    sys.exit(0)


if __name__ == '__main__':
    version()
