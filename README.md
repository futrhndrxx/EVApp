# EVApp



## Installations Instructions
Required Software: Xcode, CocoaPods
- Clone Project
- On the Terminal, navigate to the project folder
- On the CLI input $ pod install  
    * The command will generate a new .workspace project that will be used to run the application
    * this will install the libraries provided by the MapBox SDK
- Open the .workspace project
- Select the EVNav directory on the left hand side
- Select the Info Tab
- If not already their, create these new key-value pairs to the Custom iOS Target Properties
    * Key: MBXAccessToken, Value: pk.eyJ1IjoiZGllZ29hbTI4IiwiYSI6ImNsMnI2MTgydTBnMTYzZXF2MDdsZHlyYXcifQ.P17ggszhO1Z2Rroq4f6vNA
          ~ Token to access MapBox services
    * Key: Privacy - Location Always and When In Use Usage Description, 
      Value: pk.eyJ1IjoiZGllZ29hbTI4IiwiYSI6ImNsMnI2MTgydTBnMTYzZXF2MDdsZHlyYXcifQ.P17ggszhO1Z2Rroq4f6vNA
- In the top center, change the simulation to iPhone 11
- After that build and run the application using the Play button on the top Left
      
If issues connecting occur follow these steps in the Terminal:
  - $ cd ~
  - $ touch .netrc
  - $ open .netrc
  - Copy/Paste:
    machine api.mapbox.com
    login mapbox
    password sk.eyJ1IjoiZGllZ29hbTI4IiwiYSI6ImNsMnI2bjdpNDAzNmgzaWwyY2RmcmQxY3QifQ.3gsHs5mL5UinTgUWWgw63w


## Video Walkthrough

Gas Vehicle Walkthrough:

<img src="http://g.recordit.co/kQfYiZcBFb.gif" title='Video Walkthrough' width='' alt='Video Walkthrough' />


Electric Vehicle Walkthrough

<img src= "http://g.recordit.co/c5wOwydtIB.gif" title='Video Walkthrough' width='' alt='Video Walkthrough' />
