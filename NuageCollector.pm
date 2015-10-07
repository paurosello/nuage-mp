# OPC_WHAT_STRING="@WHAT_STRING@"
package NuageCollector;
use base 'Collector';

use strict;
use Collector;
use Data::Dumper;

use LWP::UserAgent;
use HTTP::Request;
use Time::HiRes qw( time );
use JSON qw( decode_json );

sub run
{
  my $self = shift;
  my $config = $self->getConfig();

  $self->log("Init with Interval: ".$config->[1]->{interval});

  $self->log($self->INFO, "InstallDir:   $self->{installDir}");
  $self->log($self->INFO, "DataDir:      $self->{dataDir}");
  $self->log($self->INFO, "InstrDir:     $self->{instrumentationDir}");
  $self->log($self->INFO, "AgentVersion: ".$self->{agentVersionMajor}.".".$self->{agentVersionMinor});
  
  return 1;
}

sub topology
{
	my $self = shift;
	my $isTopo = shift;
	my $config = $self->getConfig();
  
    my $ost_cfg;
	my $vsd_username;	
	my $vsd_password;
	my $vsd_enterprise;
	my $vsd_api_version;
	my $vsd_api_url;
	
	if($isTopo eq "true" && $self->{isProduction}) {
		$ost_cfg = $self->getOstCfg();
		$vsd_username = $ost_cfg->{vsd_username};
		$vsd_password = $ost_cfg->{vsd_password};
		$vsd_enterprise = $ost_cfg->{vsd_enterprise};
		$vsd_api_version = $ost_cfg->{vsd_api_version};
		$vsd_api_url = $ost_cfg->{vsd_api_url};
	}
	else
	{ 
		$vsd_username = "";
		$vsd_enterprise = "";
		$vsd_password = "";
		$vsd_api_version =  "";
		$vsd_api_url = "";
	}
	
	$self->log($self->INFO,  "##### vsd_username is       : $vsd_username");
	$self->log($self->INFO,  "##### vsd_password is        : ********");
	$self->log($self->INFO,  "##### vsd_enterprise is     : $vsd_enterprise");
	$self->log($self->INFO,  "##### vsd_api_version is      : $vsd_api_version");
	$self->log($self->INFO,  "##### vsd_api_url is     : $vsd_api_url");
  
	my @result = ();

	my $new_ci = {};
	$new_ci->{type}    = "ci_collection";
	$new_ci->{name}    = "NuageTopology";
	push(@result, $new_ci);
		
	my $command = "/var/opt/OV/bin/instrumentation/vsd list  --username $vsd_username --password  $vsd_password --api $vsd_api_url --enterprise  $vsd_enterprise --version $vsd_api_version --json";
	
	my $enterprises = `$command  enterprises`;
	$self->log($self->INFO, $enterprises);
	
	my @decoded_enterprises = @{decode_json($enterprises)};

	foreach my $enterprise (@decoded_enterprises){
		
		#Base Attributes
		my $new_ci = {};
		$new_ci->{type}    = "dcn_enterprise";
		$new_ci->{name}    = $enterprise->{"ID"};
		$new_ci->{user_label} = $enterprise->{"name"};
		$new_ci->{dcn_id} = $enterprise->{"ID"};
		
		#CI Attributes
		$new_ci->{AllowAdvancedQOSConfiguration} = sanitize( $enterprise->{"allowAdvancedQOSConfiguration"});
		$new_ci->{AllowedForwardingClasses} = join(",", @{$enterprise->{"allowedForwardingClasses"}});
		$new_ci->{AllowGatewayManagement} = sanitize( $enterprise->{"allowGatewayManagement"});
		$new_ci->{AllowTrustedForwardingClass} = sanitize( $enterprise->{"allowTrustedForwardingClass"});		
		$new_ci->{AvatarData} = sanitize( $enterprise->{"avatarData"});
		$new_ci->{AvatarType} = sanitize( $enterprise->{"avatarType"});
		$new_ci->{FloatingIPsQuota} = sanitize( $enterprise->{"floatingIPsQuota"});
		$new_ci->{FloatingIPsUsed} = sanitize( $enterprise->{"floatingIPsUsed"});
		
		#Relations
		$new_ci->{member_of} = "ci_collection_NuageTopology";

		push(@result, $new_ci);
	} 
	
	my $domains = `$command domains`;
	$self->log($self->DEBUG, $domains);
	
	my @decoded_domains = @{decode_json($domains)};

	foreach my $domain (@decoded_domains){
		
		#Base Attributes
		my $new_ci = {};
		$new_ci->{type} = "dcn_l3domain";
		$new_ci->{name} = $domain->{"ID"};
		$new_ci->{user_label} = $domain->{"name"};
		$new_ci->{dcn_id} = $domain->{"ID"};
		
		#CI Attributes
		$new_ci->{MaintenanceMode} = sanitize( $domain->{"maintenanceMode"});
		$new_ci->{RouteDistinguisher} = sanitize( $domain->{"routeDistinguisher"});
		$new_ci->{RouteTarget} = sanitize( $domain->{"routeTarget"});
		$new_ci->{ApplicationDeploymentPolicy} = sanitize( $domain->{"applicationDeploymentPolicy"});
		$new_ci->{BackHaulRouteDistinguisher} = sanitize( $domain->{"backHaulRouteTarget"});
		$new_ci->{BackHaulRouteTarget} = sanitize( $domain->{"backHaulRouteTarget"});
		$new_ci->{BackHaulVNID} = sanitize( $domain->{"backHaulVNID"});
		$new_ci->{DHCPBehavior} = sanitize( $domain->{"DHCPBehavior"});
		$new_ci->{DHCPServerAddress} = sanitize( $domain->{"DHCPServerAddress"});
		$new_ci->{TunnelType} = sanitize( $domain->{"tunnelType"});
		$new_ci->{Multicast} = sanitize( $domain->{"multicast"});
		$new_ci->{AssociatedMulticastChannelMapID} = sanitize( $domain->{"associatedMulticastChannelMapID"});
		
		#Relations
		$new_ci->{member_of} = "dcn_enterprise_" . $domain->{"parentID"};
		
		push(@result, $new_ci);
	} 
	
	my $zones = `$command zones`;
	$self->log($self->DEBUG, $zones);
	
	my @decoded_zones = @{decode_json($zones)};

	foreach my $zone (@decoded_zones){
		
		#Base Attributes
		my $new_ci = {};
		$new_ci->{type} = "dcn_zone";
		$new_ci->{name} = $zone->{"ID"};
		$new_ci->{user_label} = $zone->{"name"};
		$new_ci->{dcn_id} = $zone->{"ID"};
		
		#CI Attributes
		$new_ci->{Address} = sanitize( $zone->{"address"});
		$new_ci->{IPType} = sanitize( $zone->{"IPType"});
		$new_ci->{MaintenanceMode} = sanitize( $zone->{"maintenanceMode"});
		$new_ci->{Netmask} = sanitize( $zone->{"netmask"});
		$new_ci->{NumberOfHostsInSubnets} = sanitize( $zone->{"numberOfHostsInSubnets"});
		$new_ci->{PolicyGroupId} = sanitize( $zone->{"policyGroupId"});
		$new_ci->{PublicZone} = sanitize( $zone->{"publicZone"});
		$new_ci->{Multicast} = sanitize( $zone->{"multicast"});
		#$new_ci->{encryption} = sanitize( $zone->{"encryption"});
		$new_ci->{AssociatedMulticastChannelMapID} = sanitize( $zone->{"associatedMulticastChannelMapID"});
		
		#Relations
		$new_ci->{member_of} = "dcn_l3domain_" . $zone->{"parentID"};
		
		push(@result, $new_ci);
	}
	
	my $subnets = `$command subnets`;
	$self->log($self->DEBUG, $subnets);
	
	my @decoded_subnets = @{decode_json($subnets)};
	
	foreach my $subnet (@decoded_subnets){
		
		#Base Attributes
		my $new_ci = {};
		$new_ci->{type} = "dcn_subnetwork";
		$new_ci->{name} = $subnet->{"ID"};
		$new_ci->{user_label} = $subnet->{"name"};
		$new_ci->{dcn_id} = $subnet->{"ID"};
		
		#CI Attributes
		$new_ci->{Address} = sanitize( $subnet->{"address"});
		$new_ci->{AssociatedSharedNetworkResourceID} = sanitize( $subnet->{"associatedSharedNetworkResourceID"});
		$new_ci->{DefaultAction} = sanitize( $subnet->{"defaultAction"});
		$new_ci->{Gateway} = sanitize( $subnet->{"gateway"});
		$new_ci->{GatewayMACAddress} = sanitize( $subnet->{"gatewayMACAddress"});
		$new_ci->{IPType} = sanitize( $subnet->{"IPType"});
		$new_ci->{MaintenanceMode} = sanitize( $subnet->{"maintenanceMode"});
		$new_ci->{Netmask} = sanitize( $subnet->{"netmask"});
		$new_ci->{PolicyGroupId} = sanitize( $subnet->{"policyGroupId"});
		$new_ci->{Public} = sanitize( $subnet->{"publicNetwork"});
		$new_ci->{RouteDistinguisher} = sanitize( $subnet->{"routeDistinguisher"});
		$new_ci->{RouteTarget} = sanitize( $subnet->{"routeTarget"});
		$new_ci->{VnId} = sanitize( $subnet->{"vnId"});
		$new_ci->{Multicast} = sanitize( $subnet->{"multicast"});
		#$new_ci->{encryption} = sanitize( $subnet->{"encryption"});
		$new_ci->{AssociatedMulticastChannelMapID} = sanitize( $subnet->{"associatedMulticastChannelMapID"});
		$new_ci->{ProxyARP} = sanitize( $subnet->{"proxyARP"});
		$new_ci->{SplitSubnet} = sanitize( $subnet->{"splitSubnet"});
		
		#Relations
		$new_ci->{member_of} = "dcn_zone_" . $subnet->{"parentID"};
		
		push(@result, $new_ci);
	} 
	
	return @result;
}

sub getOstCfg()
{
  require OvParam;

  my %ost_cfg = {};

  my $template = new OvParam::Template();
  $template->Load('Nuage_Alcatel_Lucent_Configuration', "configfiletmpl");

  my $vsd_username_param = $template->GetSimpleParameter("VSD_USERNAME");
  my $vsd_username = $vsd_username_param->GetValue();
  $ost_cfg{vsd_username} = $vsd_username;

  my $vsd_password_param = $template->GetSimpleParameter("VSD_PASSWORD");
  my $vsd_password = $vsd_password_param->GetValue();
  $ost_cfg{vsd_password} = $vsd_password;

  my $vsd_enterprise_param = $template->GetSimpleParameter("VSD_ENTERPRISE");
  my $vsd_enterprise = $vsd_enterprise_param->GetValue();
  $ost_cfg{vsd_enterprise} = $vsd_enterprise;

  my $vsd_api_version_param = $template->GetSimpleParameter("VSD_API_VERSION");
  my $vsd_api_version = $vsd_api_version_param->GetValue();
  $ost_cfg{vsd_api_version} = $vsd_api_version;
  
  my $vsd_api_url_param = $template->GetSimpleParameter("VSD_API_URL");
  my $vsd_api_url = $vsd_api_url_param->GetValue();
  $ost_cfg{keystone_purl} = $vsd_api_url;

  return \%ost_cfg;
}

sub sanitize{
	my $input = shift;
	return defined $input ? $input : "null";
}

1;