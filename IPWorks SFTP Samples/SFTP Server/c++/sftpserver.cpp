/*
 * IPWorks SFTP 2024 C++ Edition - Sample Project
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

/*
 * IPWorks SFTP 2024 C++ Edition - Sample Project
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

#include <iostream>
#include <string>
#include <map>
#include <sstream>
#include "../../include/ipworkssftp.h"

using namespace std;

class MySFTPServer : public SFTPServer
{
public:
  MySFTPServer()
  {
  }

  // -----------------------------
  // Event Handlers
  // -----------------------------

  virtual int FireConnectionRequest(SFTPServerConnectionRequestEventParams* e) {
    std::cout << e->Address << ":" << to_string(e->Port) << " is attempting to connect." << "\n";
    e->Accept = true;
    return 0;
  }

  virtual int FireSSHUserAuthRequest(SFTPServerSSHUserAuthRequestEventParams* e) {
    // Accept all users for demo purposes
    e->Accept = true;
    std::cout << e->User << " has successfully authenticated." << "\n";
    return 0;
  }

  virtual int FireLogEvent(SFTPServerLogEventParams* e) {
    std::cout << e->ConnectionId << ": " << e->Message << "\n";
    return 0;
  }

  virtual int FireConnected(SFTPServerConnectedEventParams* e) {
    std::cout << e->ConnectionId <<
      string("Now Connected - ") << e->Description <<
      " (" << to_string(e->StatusCode) << ")" << "\n";
    return 0;
  }

  virtual int FireDisconnected(SFTPServerDisconnectedEventParams* e) {
    std::cout << e->ConnectionId <<
      string("Now Disconnected - ") << e->Description <<
      " (" << to_string(e->StatusCode) << ")" << "\n";
    return 0;
  }

  virtual int FireFileOpen(SFTPServerFileOpenEventParams* e) {
    string operation;

    if (e->Flags & 1)
      operation = "downloading";

    if (e->Flags & 2)
      operation = "uploading";

    if (!e->BeforeExec)
      std::cout << string(e->User) << " started " << operation << " " << e->Path << "\n";

    return 0;
  }

  virtual int FireFileClose(SFTPServer* sender, SFTPServerFileCloseEventParams* e) {
    std::cout << string(e->User) << " transferred " << e->Path << "\n";
    return 0;
  }

  virtual int FireFileRemove(SFTPServer* sender, SFTPServerFileRemoveEventParams* e) {
    if (!e->BeforeExec)
      std::cout << string(e->User) << " deleted a file: " << e->Path << "\n";
    return 0;
  }

  virtual int FireDirCreate(SFTPServer* sender, SFTPServerDirCreateEventParams* e) {
    if (!e->BeforeExec)
      std::cout << string(e->User) << " created a directory: " << e->Path << "\n";
    return 0;
  }

  virtual int FireDirRemove(SFTPServer* sender, SFTPServerDirRemoveEventParams* e) {
    if (!e->BeforeExec)
      std::cout << string(e->User) << " deleted a directory: " << e->Path << "\n";
    return 0;
  }

  virtual int FireError(SFTPServer* sender, SFTPServerErrorEventParams* e) {
    std::cout << e->ConnectionId <<
      string("Error - ") << e->Description <<
      " (" << to_string(e->ErrorCode) << ")";
    return 0;
  }
};
std::map<std::string, std::string> ParseArgs(int argc, char* argv[]) {
  std::map<std::string, std::string> result;

  for (int i = 1; i < argc; ++i) {
    std::string arg = argv[i];
    if (arg[0] == '/' || arg[0] == '-')
      arg = arg.substr(1);

    if (i + 1 < argc) {
      result[arg] = argv[++i];
    }
  }
  return result;
}



// -----------------------------
// Main
// -----------------------------

int main(int argc, char** argv) {

  try {
    std::cout << "This demo shows how to use the SFTPServer Component to create a simple SFTP Server.\n";
    std::cout << "Press Ctrl+C to shutdown the server.\n";

    if (argc != 2) {
      std::cout << "usage: sftpserver [/port port] [/root rootdir] [/user user] [/pass password]\n";
      std::cout << "  port     the port to listen on (default 22)\n";
      std::cout << "  root     the root directory of the server (default ./)\n";
      std::cout << "  user     username to use during logon (optional)\n";
      std::cout << "  pass     password for the user (optional)\n";

      std::cout << "\nExample: sftpserver /port 22 /root C://temp \n\n";
      std::cout << "Press enter to continue.\n";
      getchar();
    }

    auto args = ParseArgs(argc, argv);

    int port = args.count("port") ? stoi(args["port"]) : 22;
    string rootDir = args.count("root") ? args["root"] : "./";

    // Register event handlers
    MySFTPServer sftpserver;
    // Configure certificate
    const string CERT_STORE = "sftpserver.pfx";
    const string CERT_PASS = "demo";

    sftpserver.SetSSHCertStoreType(CST_AUTO);
    sftpserver.SetSSHCertStore(CERT_STORE.c_str(), CERT_STORE.length());
    sftpserver.SetSSHCertStorePassword(CERT_PASS.c_str());
    sftpserver.SetSSHCertSubject("*");

    sftpserver.SetLocalPort(port);
    sftpserver.SetRootDirectory(rootDir.c_str());


    int ret = sftpserver.StartListening();

    if (ret != 0) {
      cout << "Failed to start server: " << sftpserver.GetLastError() << endl;
      return 0;
    }
    cout << "SFTP server started with root directory "
      << rootDir << ". Listening on port "
      << port << ".\n";

    cout << "Type '?' for commands.\n";
    bool running = true;
    string input;
    while (running) {
      sftpserver.DoEvents();  // handle timers, GUI events, network, etc
    }
    // Command loop


  }
  catch (const exception& ex) {
    cout << "Error: " << ex.what() << endl;
  }

  return 0;
}




