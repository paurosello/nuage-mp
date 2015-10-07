#Nuage Management Pack for HP Operations Manager i

##This Management Pack (MP) requires these prerequisites:
* HP Operations Manager i (OMi) 10.00 or higher
* HP Operations Agent 11.12 or higher

	Note: The MP depends on the Monitor Framework package which must be installed prior to installing this MP.
    To check if the Monitor Framework is installed, 
    navigate to Administration > Setup and Maintenance > Content Pack
    and verify the availability of Monitor Framework under Content Pack Definition.
    It is recommended that you check and install the higher version of the Monitor Framework
    available under OMi Management Pack Development Kit at
               http://www.hp.com/go/livenetwork
    for the latest features and quality enhancements.

##Python Requirements
Python Version: 2.7.X
###Python Packages
* vsdcli
* colorama
* tabulate
* vspk
* bambou
* requests>=2.4.3





##Installation instructions
  1.  Download the zip file(s) to your local hard disc.
  2.  If there is an RTSM package, navigate to 
      Administration > RTSM Administration > Administration > Package Manager
      Then click 'Deploy packages to server (from local disk)' and select the RTSM package
  3.  In OMi, navigate to the Content Manager: Administration > Setup and Maintenance > Content Packs
      Click on 'Import Content Pack Definitions and Content' to upload the MP.



This MP requires an agent to be installed on the monitored node.
Consult the OMi documentation on how to install and connect the HP Operations Agent 11.12 or higher.


##Using the Management Pack
  1.  In OMi, navigate to Monitoring, Management Templates & Aspects
  2.  Open the folder "Nuage" Management
  3.  Open the folder "NuageCollector"
  4.  Deploy the aspect "NuageCollector Discovery" to the node on which the application runs
      This will run the discovery periodically and submit CIs to the RTSM.
  5.  For metric collection deploy "NuageCollector Collector" to collect metrics
  6.  For performance monitoring deploy the aspect "NuageCollector Performance".
      When this aspect is deployed events get generated when thresholds are crossed.
  7.  For availabilty monitoring deploy the aspect "NuageCollector Availability"
      Events will be generated if the application is not running. If you deploy only the discovery
      aspect and the collector, no event will be generated in case the application is not running.

  Consult the OMi documentation for more information on aspect deployment.



##Aspects and Parameters:

###Aspect: Nuage_Alcatel_Lucent Collector
        Description: Nuage_Alcatel_Lucent Collector

        Policy:      Nuage_Alcatel_Lucent_Configuration, 1.9
        Version:     7c60ed95-9b59-42a1-b239-4bcf1cfa5ce0
        Id:          2edb5e06-b1e0-44bc-8b0d-d55e9c7343c8
        Parameters:
                   Interval (ENUMERATION, Key: INTERVAL)
                         Default: High
                   Username With API Access Enable (STRING, Key: VSD_USERNAME)
                         Default: vsd_username
                   Password For Suplied Username (PASSWORD, Key: VSD_PASSWORD)
                         Default: vsd_password
                   Enterprise (STRING, Key: VSD_ENTERPRISE)
                         Default: vsd_enterprise
                   API Version Ex: 3.0 (STRING, Key: VSD_API_VERSION)
                         Default: 3.0
                   API URL Including Protocol And Port Ex: Https://10.3.175.7:8443 (STRING, Key: VSD_API_URL)
                         Default: https://X.X.X.X:8443


###Aspect: Nuage_Alcatel_Lucent Discovery
        Description: Aspect to discover the topology of Nuage_Alcatel_Lucent

        Policy:      Nuage_Alcatel_Lucent_Discovery_Configuration, 1.9
        Version:     8af088aa-2f6b-4558-82da-5458caec6b00
        Id:          44c3c84b-8be8-4a5d-b461-94c8df1faca9
        Parameters:

        Policy:      Nuage_Alcatel_Lucent_Discovery, 1.9
        Version:     2d3e9bfa-bd04-4610-a8e3-db233613c1d0
        Id:          a36c2505-40bf-4a06-81b6-2f3009ffc625
        Parameters:
                   Discovery Schedule (Hours Of Day) (String, Key: HOURS)
                         Default: 1,3,5,7,9,11,13,15,17,19,21,23