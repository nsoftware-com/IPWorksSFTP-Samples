<?php
/*
 * IPWorks SFTP 2024 PHP Edition - Sample Project
 *
 * This sample project demonstrates the usage of IPWorks SFTP in a 
 * simple, straightforward way. It is not intended to be a complete 
 * application. Error handling and other checks are simplified for clarity.
 *
 * www.nsoftware.com/ipworkssftp
 *
 * This code is subject to the terms and conditions specified in the 
 * corresponding product license agreement which outlines the authorized 
 * usage and restrictions.
 */
require_once('../include/ipworkssftp_sftpclient.php');
require_once('../include/ipworkssftp_const.php');
?>
<?php
class MySFTP extends IPWorksSFTP_SFTPClient {
  function FireSSHServerAuthentication($param) {
    $param['accept'] = true;
    /*
      This demo uses the above setting to unconditionally accept the server's host key.
      In production you can set the SSHAcceptServerHostKeyFingerPrint configuration setting to the 16-byte MD5 fingerprint
      to explictly accept only one host key value (see Configuration section in the help file for more detail).
      You may also set the SSHAcceptServerHostKeyEncoded property to the public key file in PEM format
    */
    return $param;
  }
  function FireDirList($param) {
    echo $param['direntry'] . "\n";
  }
  function FireError($param) {
    echo $param['description'] . "\n";
  }
  function FireLog($param) {
    echo $param['message'] . "\n";
  }
}

if ($argc < 4) {
  echo "Usage: php sftp_client.php host user pass\n\n";
  echo "  host: the host to connect to\n";
  echo "  user: the username to use for authentication\n";
  echo "  pass: the password to use for authentication\n\n";
  echo "Example: php sftp_client.php 192.168.1.2 myusername mypassword\n";
  return;
} else {
  $remoteHost = $argv[1];
  $user = $argv[2];
  $password = $argv[3];
}

function input($prompt) {
  echo $prompt;
  $handle = fopen("php://stdin", "r");
  $data = trim(fgets($handle));
  fclose($handle);
  return $data;
}

try {
  $sftp = new MySFTP();
  $sftp->setSSHHost($remoteHost);
  $sftp->setSSHAuthMode(2); // password
  $sftp->setSSHUser($user);
  $sftp->setSSHPassword($password);

  // Default port for SFTP is 22
  $sftp->doSSHLogon($remoteHost, 22);
  echo "Type \"?\" for a list of commands.\n";

  while (true) {
    try {
      $sftp->setRemoteFile("");
      $data = input("sftp> ");
      $arguments = explode(" ", $data);
      $command = $arguments[0];

      if ($command == "?" || $command == "help") {
        echo "?       cd      ls      pwd\n";
        echo "get     put     rm      mv\n";
        echo "mkdir   rmdir   exit\n";
      } elseif ($command == "bye" || $command == "quit" || $command == "exit") {
        $sftp->doSSHLogoff();
        break;
      } elseif ($command == "cd") {
        if (count($arguments) > 1) {
          $sftp->doChangeRemotePath($arguments[1]);
        } else {
          echo "Usage: cd <path>\n";
        }
      } elseif ($command == "get") {
        // get <remotefile> [<localfile>]
        if (count($arguments) < 2) {
          $sftp->setRemoteFile(input("Remote File: "));
          $sftp->setLocalFile(input("Local File: "));
        } elseif (count($arguments) == 2) {
          $sftp->setRemoteFile($arguments[1]);
          $sftp->setLocalFile($arguments[1]);
        } else {
          $sftp->setRemoteFile($arguments[1]);
          $sftp->setLocalFile($arguments[2]);
        }
        $sftp->doDownload();
        echo "File downloaded\n";
      } elseif ($command == "put") {
        // put <localfile> <remotefile>
        if (count($arguments) < 2) {
          $sftp->setLocalFile(input("Local File: "));
          $sftp->setRemoteFile(input("Remote File: "));
        } elseif (count($arguments) == 3) {
          $sftp->setLocalFile($arguments[1]);
          $sftp->setRemoteFile($arguments[2]);
        } else {
          echo "Usage: put <localFile> <remoteFile>\n";
          continue;
        }
        $sftp->doUpload();
        echo "File uploaded\n";
      } elseif ($command == "ls") {
        if (count($arguments) > 1) {
          $pathname = $sftp->getRemotePath();
          $sftp->doChangeRemotePath($arguments[1]);
          $sftp->doListDirectory();
          $sftp->doChangeRemotePath($pathname);
        } else {
          $sftp->doListDirectory();
        }
      } elseif ($command == "pwd") {
        echo $sftp->getRemotePath() . "\n";
      } elseif ($command == "mkdir") {
        if (count($arguments) > 1) {
          $sftp->doMakeDirectory($arguments[1]);
        } else {
          echo "Usage: mkdir <directory>\n";
        }
      } elseif ($command == "rmdir") {
        if (count($arguments) > 1) {
          $sftp->doRemoveDirectory($arguments[1]);
        } else {
          echo "Usage: rmdir <directory>\n";
        }
      } elseif ($command == "rm" || $command == "delete") {
        if (count($arguments) > 1) {
          $sftp->doDeleteFile($arguments[1]);
        } else {
          echo "Usage: rm <remoteFile>\n";
        }
      } elseif ($command == "mv") {
        if (count($arguments) > 2) {
          $sftp->setRemoteFile($arguments[1]);
          $sftp->doRenameFile($arguments[2]);
        } else {
          echo "Usage: mv <filename> <newFileName>\n";
        }
      } elseif ($command == "") {
        // do nothing
      } else {
        echo "Bad command / Not implemented in demo.\n";
      }
    } catch (Exception $ex) {
      echo "Error: " . $ex->getMessage() . "\n";
    }
  }
} catch (Exception $e) {
  echo "Error: " . $e->getMessage() . "\n";
}

input("\npress <return> to continue...");

?>