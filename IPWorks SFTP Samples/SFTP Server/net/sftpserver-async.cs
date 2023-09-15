/*
 * IPWorks SFTP 2022 .NET Edition - Sample Project
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

using System.Collections.Generic;
﻿using System;
using System.Threading.Tasks;
using nsoftware.async.IPWorksSFTP;

class sftpserverDemo
{
	private static Sftpserver sftpserver = new nsoftware.async.IPWorksSFTP.Sftpserver();

  static async Task Main(string[] args)
  {
    sftpserver.OnConnectionRequest += sftpserver_OnConnectionRequest;
    sftpserver.OnSSHUserAuthRequest += sftpserver_OnSSHUserAuthRequest;
    sftpserver.OnLog += sftpserver_OnLog;
    sftpserver.OnConnected += sftpserver_OnConnected;
    sftpserver.OnDisconnected += sftpserver_OnDisconnected;
    sftpserver.OnFileOpen += sftpserver_OnFileOpen;
    sftpserver.OnFileClose += sftpserver_OnFileClose;
    sftpserver.OnFileRemove += sftpserver_OnFileRemove;
    sftpserver.OnDirCreate += sftpserver_OnDirCreate;
    sftpserver.OnDirRemove += sftpserver_OnDirRemove;
    sftpserver.OnError += sftpserver_OnError;

    try
    {
      Console.WriteLine("usage: sftpserver [/port port] [/root rootdir]\n");
      Console.WriteLine("  port         the port to listen on (optional, default 22)");
      Console.WriteLine("  rootdir      the root directory of the server (optional, default current directory)");
      Console.WriteLine("\nExample: sftpserver /port 1234 /root c:\\sftpdemo\n");

      Dictionary<string, string> myArgs = ConsoleDemo.ParseArgs(args);
      int port = myArgs.ContainsKey("port") ? int.Parse(myArgs["port"]) : 22;
      string rootDir = myArgs.ContainsKey("root") ? myArgs["root"] : "./";

      // Change this to the path to the server's SSH certificate store (e.g. a .pfx or .pem file).
      const string CERT_STORE = "..\\..\\..\\sftpserver.pfx";

      // Change this to the certificate store password.
      const string CERT_PASS = "demo";

      // Set up the SFTP server.
      sftpserver.SSHCert = new Certificate(CertStoreTypes.cstAuto, CERT_STORE, CERT_PASS, "*");
      sftpserver.LocalPort = port;
      sftpserver.RootDirectory = rootDir;
      await sftpserver.StartListening();
      Console.WriteLine("SFTP server started with root directory " + sftpserver.RootDirectory + ". Listening on port " + sftpserver.LocalPort + ".");
      Console.WriteLine("Note: For the purposes of this demo, you can authenticate with any user and any password.");

      Console.WriteLine("Type \"?\" for a list of commands.");
      Console.Write("sftpserver> ");
      string command;
      string[] arguments;
      while (true)
      {
        command = Console.ReadLine();
        arguments = command.Split();

        if (arguments[0].Equals("?") || arguments[0].Equals("help"))
        {
          Console.WriteLine("Commands: ");
          Console.WriteLine("  ?                            display the list of valid commands");
          Console.WriteLine("  help                         display the list of valid commands");
          Console.WriteLine("  users                        list all currently connected users");
          Console.WriteLine("  disconnect <id>              disconnect client by id");
          Console.WriteLine("  quit                         exit the application");
        }
        else if (arguments[0].Equals("quit") || arguments[0].Equals("exit"))
        {
          await sftpserver.Shutdown();
          Console.WriteLine("SFTP server stopped.");
          break;
        }
        else if (arguments[0].Equals("users"))
        {
          foreach (SFTPConnection conn in sftpserver.Connections.Values)
          {
            Console.WriteLine(conn.ConnectionId);
          }
        }
        else if (arguments[0].Equals("disconnect"))
        {
          if (arguments.Length > 1) await sftpserver.Disconnect(arguments[1]);
        }
        else if (arguments[0].Equals(""))
        {
          // Do nothing.
        }
        else
        {
          Console.WriteLine("Invalid command.");
        } // End of command checking.

        Console.Write("sftpserver> ");
      }
    }
    catch (Exception ex)
    {
      Console.WriteLine("Error: " + ex.Message);
    }
  }

  private static void Log(string msg)
  {
    Console.WriteLine(msg);
  }

  private static void Log(string connID, string msg)
  {
    Log("[" + connID + "]: " + msg);
  }

  #region "Events"

  private static void sftpserver_OnConnectionRequest(object sender, SftpserverConnectionRequestEventArgs e)
  {
    Log(e.Address + ":" + e.Port.ToString() + " is attempting to connect.");
  }

  private static void sftpserver_OnSSHUserAuthRequest(object sender, SftpserverSSHUserAuthRequestEventArgs e)
  {
    // Here is where you would check that the "user" and "password" arguments match e.User and e.AuthParam respectively.
    // For the purposes of this demo, all users are accepted.
    e.Accept = true;
    Log(e.User + " has successfully authenticated.");
  }

  private static void sftpserver_OnLog(object sender, SftpserverLogEventArgs e)
  {
    Log(e.ConnectionId, e.Message);
  }

  private static void sftpserver_OnConnected(object sender, SftpserverConnectedEventArgs e)
  {
    Log(e.ConnectionId, "Now Connected - " + e.Description + " (" + e.StatusCode.ToString() + ")");
  }

  private static void sftpserver_OnDisconnected(object sender, SftpserverDisconnectedEventArgs e)
  {
    Log(e.ConnectionId, "Now Disconnected - " + e.Description + " (" + e.StatusCode.ToString() + ")");
  }

  private static void sftpserver_OnFileOpen(object sender, SftpserverFileOpenEventArgs e)
  {
    string operation = "";

    if ((e.Flags & 1) != 0)
    {
      // A read operation.
      operation = "downloading";
    }
    if ((e.Flags & 2) != 0)
    {
      // A write operation.
      operation = "uploading";
    }
    if (!e.BeforeExec) Log(e.User + " started " + operation + " " + e.Path);
  }

  private static void sftpserver_OnFileClose(object sender, SftpserverFileCloseEventArgs e)
  {
    Log(e.User + " transferred " + e.Path);
  }

  private static void sftpserver_OnFileRemove(object sender, SftpserverFileRemoveEventArgs e)
  {
    if (!e.BeforeExec) Log(e.User + " deleted a file: " + e.Path);
  }

  private static void sftpserver_OnDirCreate(object sender, SftpserverDirCreateEventArgs e)
  {
    if (!e.BeforeExec) Log(e.User + " created a directory: " + e.Path);
  }

  private static void sftpserver_OnDirRemove(object sender, SftpserverDirRemoveEventArgs e)
  {
    if (!e.BeforeExec) Log(e.User + " deleted a directory: " + e.Path);
  }

  private static void sftpserver_OnError(object sender, SftpserverErrorEventArgs e)
  {
    Log(e.ConnectionId, "Error - " + e.Description + " (" + e.ErrorCode.ToString() + ")");
  }

  #endregion
}


class ConsoleDemo
{
  public static Dictionary<string, string> ParseArgs(string[] args)
  {
    Dictionary<string, string> dict = new Dictionary<string, string>();

    for (int i = 0; i < args.Length; i++)
    {
      // If it starts with a "/" check the next argument.
      // If the next argument does NOT start with a "/" then this is paired, and the next argument is the value.
      // Otherwise, the next argument starts with a "/" and the current argument is a switch.

      // If it doesn't start with a "/" then it's not paired and we assume it's a standalone argument.

      if (args[i].StartsWith("/"))
      {
        // Either a paired argument or a switch.
        if (i + 1 < args.Length && !args[i + 1].StartsWith("/"))
        {
          // Paired argument.
          dict.Add(args[i].TrimStart('/'), args[i + 1]);
          // Skip the value in the next iteration.
          i++;
        }
        else
        {
          // Switch, no value.
          dict.Add(args[i].TrimStart('/'), "");
        }
      }
      else
      {
        // Standalone argument. The argument is the value, use the index as a key.
        dict.Add(i.ToString(), args[i]);
      }
    }
    return dict;
  }

  public static string Prompt(string prompt, string defaultVal)
  {
    Console.Write(prompt + (defaultVal.Length > 0 ? " [" + defaultVal + "]": "") + ": ");
    string val = Console.ReadLine();
    if (val.Length == 0) val = defaultVal;
    return val;
  }
}