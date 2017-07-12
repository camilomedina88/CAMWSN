# SIP-related methods and initializations

# Defaults
# Record route: 0 (no), 1 (yes) or 2 (not if home proxy for a romaing user)
Agent/SIPProxy set recordRoute_ 0
Agent/SIPProxy set send100_ 1
Agent/SIPProxy set min_ 0
Agent/SIPProxy set max_ 0



#Overload Controlled Proxy Settings
Agent/OCProxy set recordRoute_ 0
Agent/OCProxy set sipdelay_ 0.0
Agent/OCProxy set sdpdelay_ 0.0
Agent/OCProxy set send100_ 1
Agent/OCProxy set send503_ 0
Agent/OCProxy set unacoda_ 0
Agent/OCProxy set duecode_ 0
Agent/OCProxy set min_ 0
Agent/OCProxy set max_ 0
Agent/OCProxy set TH_HIGH_ 0
Agent/OCProxy set TH_LOW_ 0
Agent/OCProxy set dim_MAX_ 0
Agent/OCProxy set TH_HIGHINV_ 0
Agent/OCProxy set TH_LOWINV_ 0
Agent/OCProxy set dim_MAXINV_ 0
Agent/OCProxy set dim_MAXnnINV_ 0
Agent/OCProxy set priorita_ 0

# Simple session setup: INVITE, 200 OK, ACK
Agent/SIPUA set simple_ 1
# Minimum and maximum delay to pick up the phone after ringing (if !simple_)
Agent/SIPUA set minAnsDel_ 1.0
Agent/SIPUA set maxAnsDel_ 9.0
Agent/SIPUA set min_ 0
Agent/SIPUA set max_ 0

# Processing delays
Agent/SIPUA set sipdelay_ 0.0
Agent/SIPUA set sdpdelay_ 0.0
Agent/SIPProxy set sipdelay_ 0.0
Agent/SIPProxy set sdpdelay_ 0.0



# Notification that the registration succeeded
# Change it to do something more useful than print a message
Agent/SIPUA instproc reg-ok { node user domain ruser rdomain } {
#   puts "Node $node: $user@$domain successfully registered contact $ruser@$rdomain"
}

# Notification that the registration failed
Agent/SIPUA instproc reg-failed { node user domain ruser rdomain code } {
#   puts "Node $node: registration of $user@$domain with contact $ruser@$rdomain failed with code $code"
}

# Notification that the invite succeeded
Agent/SIPUA instproc invite-ok { node callid user domain ruser rdomain} {
   puts "Node $node: session $callid from $user@$domain to $ruser@$rdomain succeeded"
}

# Notification that the invite failed
Agent/SIPUA instproc invite-failed { node callid user domain ruser rdomain code } {
   puts "Node $node: session $callid from $user@$domain to $ruser@$rdomain failed with code $code"
}

# Notification of a successfully terminated session
Agent/SIPUA instproc bye-ok { node callid user domain ruser rdomain } {
   puts "Node $node: session $callid from $user@$domain to $ruser@$rdomain terminated"
}

# Indication of a starting session, mostly for debugging purposes
Agent/SIPUA instproc starting-session { node callid user domain ruser rdomain } {
   puts "Node $node: initiating session $callid from $user@$domain to $ruser@$rdomain"
}

# Indication of an ending session, mostly for debugging purposes
Agent/SIPUA instproc ending-session { node callid user domain ruser rdomain } {
   puts "Node $node: ending session $callid from $user@$domain to $ruser@$rdomain"
}



# Method overload to allow specification of the port. Does not work with SCTP
Simulator instproc attach-agent { node agent { port "" } } {
   $node attach $agent $port
}


# Create a SIPUA and attach it to the node
Node instproc sip-ua { user domain } {
   $self instvar sipua_
   if { ! [info exists sipua_] } {
      set sipua_ [new Agent/SIPUA $user $domain]
      $self attach $sipua_ 0; # Must be at port 0
   }
   return $sipua_
}


# Create a SIP Proxy and attach it to the node
Node instproc sip-proxy { domain } {
   $self instvar sipproxy_
   if { ! [info exists sipproxy_] } {
      set sipproxy_ [new Agent/SIPProxy $domain]
      $self attach $sipproxy_ 0; # Must be at port 0
   }
   # Drop home proxy after the "200 OK" by default
   $sipproxy_ set recordRoute_ 2;
   return $sipproxy_
}

Node instproc sip-ocproxy { domain } {
   $self instvar ocproxy_
   if { ! [info exists ocproxy_] } {
      set sipproxy_ [new Agent/OCProxy $domain]
      $self attach $ocproxy_ 0; # Must be at port 0
   }
   # Drop home proxy after the "200 OK" by default
   $ocproxy_ set recordRoute_ 2;
   return $ocproxy_
}



# DNS "GOD" - Used to avoid the implementation of real DNS for use with SIP
Class DNSGod

# Register a server with a node ID, e.g., proxy ncc.up.pt 3
DNSGod proc register { host domain id } {
   DNSGod instvar $host$domain
   set $host$domain $id
}

DNSGod proc resolve { host domain } {
   DNSGod instvar $host$domain
   if { [ info exists $host$domain ] } {
      set $host$domain
   } else {
      return ""
   }
}
