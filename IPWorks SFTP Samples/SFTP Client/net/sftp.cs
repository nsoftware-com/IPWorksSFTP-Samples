/*
 * IPWorks SFTP 2024 .NET Edition - Sample Project
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
 * 
 */

﻿using System;
using nsoftware.IPWorksSFTP;

class sftpDemo
{
  private static SFTPClient sftp = new nsoftware.IPWorksSFTP.SFTPClient();

  static void Main(string[] args)
  {
    if (args.Length < 6)
    {
      Console.WriteLine("usage: sftp /s hostserver /u user /p password\n");
      Console.WriteLine("  hostserver   the host sftp server to connect to");
      Console.WriteLine("  user         the username to use for authentication");
      Console.WriteLine("  password     the password to use for authentication");
      Console.WriteLine("\nExample: sftp /s 192.168.1.2 /u myusername /p mypassword\n");
    }
    else
    {
      sftp.OnTransfer += sftp_OnTransfer;
      sftp.OnSSHServerAuthentication += sftp_OnSSHServerAuthentication;
      sftp.OnDirList += sftp_OnDirList;
      sftp.OnDisconnected += sftp_OnDisconnected;

      try
      {
        System.Collections.Generic.Dictionary<string, string> myArgs = ConsoleDemo.ParseArgs(args);

        sftp.SSHAuthMode = SFTPClientSSHAuthModes.amPassword;
        sftp.SSHHost = myArgs["s"];
        sftp.SSHUser = myArgs["u"];
        sftp.SSHPassword = myArgs["p"];

        // Default port for SFTP is 22.
        sftp.SSHLogon(sftp.SSHHost, 22);

        Console.WriteLine("Type \"?\" for a list of commands.");
        Console.Write("sftp> ");
        string command;
        string[] arguments;
        while (true)
        {
          command = Console.ReadLine();
          arguments = command.Split();

          if (arguments[0].Equals("?") || arguments[0].Equals("help"))
          {
            Console.WriteLine("?       cd      ls      pwd");
            Console.WriteLine("get     put     rm      mkdir");
            Console.WriteLine("rmdir   mv      exit");
          }
          else if (arguments[0].Equals("quit") || arguments[0].Equals("exit"))
          {
            sftp.SSHLogoff();
            break;
          }
          else if (arguments[0].Equals("cd"))
          {
            if (arguments.Length > 1) sftp.ChangeRemotePath(arguments[1]);
          }
          else if (arguments[0].Equals("get"))
          {
            if (arguments.Length > 1)
            {
              sftp.RemoteFile = arguments[1];
              sftp.LocalFile = arguments[1];
              sftp.Download();
              Console.WriteLine("File downloaded");
            }
          }
          else if (arguments[0].Equals("ls"))
          {
            if (arguments.Length > 1)
            {
              string pathname = sftp.RemotePath;
              sftp.ChangeRemotePath(arguments[1]);
              sftp.ListDirectory();
              sftp.ChangeRemotePath(pathname);
            }
            else
            {
              sftp.ListDirectory();
            }
          }
          else if (arguments[0].Equals("mkdir"))
          {
            if (arguments.Length > 1) sftp.MakeDirectory(arguments[1]);
          }
          else if (arguments[0].Equals("mv"))
          {
            if (arguments.Length > 2)
            {
              sftp.RemoteFile = arguments[1];
              sftp.RenameFile(arguments[2]);
            }
          }
          else if (arguments[0].Equals("put"))
          {
            if (arguments.Length > 2)
            {
              sftp.LocalFile = arguments[1];
              sftp.RemoteFile = arguments[2];
              sftp.Upload();
              Console.WriteLine("File uploaded");
            }
          }
          else if (arguments[0].Equals("pwd"))
          {
            Console.WriteLine(sftp.RemotePath);
          }
          else if (arguments[0].Equals("rm"))
          {
            if (arguments.Length > 1) sftp.DeleteFile(arguments[1]);
          }
          else if (arguments[0].Equals("rmdir"))
          {
            if (arguments.Length > 1) sftp.RemoveDirectory(arguments[1]);
          }
          else if (arguments[0].Equals(""))
          {
            // Do nothing.
          }
          else
          {
            Console.WriteLine("Invalid command.");
          } // End of command checking.

          sftp.RemoteFile = "";
          Console.Write("sftp> ");
        }
      }
      catch (Exception ex)
      {
        Console.WriteLine("Error: " + ex.Message);
      }
    }
  }

  #region "Events"

  private static void sftp_OnSSHServerAuthentication(object sender, SFTPClientSSHServerAuthenticationEventArgs e)
  {
    if (e.Accept) return;
    Console.Write("Server provided the following certificate:\nIssuer: " + e.CertIssuer + "\nSubject: " + e.CertSubject + "\n");
    Console.Write("The following problems have been determined for this certificate: " + e.Status + "\n");
    Console.Write("Would you like to continue anyways? [y/n] ");
    if (Console.Read() == 'y') e.Accept = true;
  }

  private static void sftp_OnTransfer(object sender, SFTPClientTransferEventArgs e)
  {
    Console.WriteLine(e.Text);
  }

  private static void sftp_OnDirList(object sender, SFTPClientDirListEventArgs e)
  {
    Console.WriteLine(e.DirEntry);
  }

  private static void sftp_OnDisconnected(object sender, SFTPClientDisconnectedEventArgs e)
  {
    Console.WriteLine("Disconnected with status code " + e.StatusCode + " and description " + e.Description);
    Environment.Exit(0);
  }

  #endregion
}




class ConsoleDemo
{
  /// <summary>
  /// Takes a list of switch arguments or name-value arguments and turns it into a dictionary.
  /// </summary>
  public static System.Collections.Generic.Dictionary<string, string> ParseArgs(string[] args)
  {
    System.Collections.Generic.Dictionary<string, string> dict = new System.Collections.Generic.Dictionary<string, string>();

    for (int i = 0; i < args.Length; i++)
    {
      // Add a key to the dictionary for each argument.
      if (args[i].StartsWith("/"))
      {
        // If the next argument does NOT start with a "/", then it is a value.
        if (i + 1 < args.Length && !args[i + 1].StartsWith("/"))
        {
          // Save the value and skip the next entry in the list of arguments.
          dict.Add(args[i].ToLower().TrimStart('/'), args[i + 1]);
          i++;
        }
        else
        {
          // If the next argument starts with a "/", then we assume the current one is a switch.
          dict.Add(args[i].ToLower().TrimStart('/'), "");
        }
      }
      else
      {
        // If the argument does not start with a "/", store the argument based on the index.
        dict.Add(i.ToString(), args[i].ToLower());
      }
    }
    return dict;
  }
  /// <summary>
  /// Asks for user input interactively and returns the string response.
  /// </summary>
  public static string Prompt(string prompt, string defaultVal)
  {
    Console.Write(prompt + (defaultVal.Length > 0 ? " [" + defaultVal + "]": "") + ": ");
    string val = Console.ReadLine();
    if (val.Length == 0) val = defaultVal;
    return val;
  }
}