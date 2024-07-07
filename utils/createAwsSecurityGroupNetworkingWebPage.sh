#!/bin/bash
#
# This script extracts nodes & edges data from the output off "aws ec2 describe-security-groups" command and create static html file for 
# network of security group using vis.js. 
#
# input: 
# - json file.  Output from "aws ec2 describe-security-groups"
# - html output file path 
#
# output: html contents written to the supplied "html output file path".  Show visual networking of security groups when open on a browser
#
# Process flow:
# - extract nodes and edges data from the input json file
# - create html file
#
# Usage: $0  <describeSgJsonFile> <outNetworkFlowFile> [edgeLabelFlag=true|false, default=true]"
#  eg: for simplify digram: $0 /path/to/describe-security-groups.json /tmp/sg-networking.siplify.html false
#  eg: for comprehensive digram (including ports info): $0 /path/to/describe-security-groups.json /tmp/sg-networking.html
#
#============================================================================================================================

#html codes base on https://visjs.github.io/vis-network/examples/network/basicUsage.html
createHtmlNetworkFlowDiagram () {
theNodes=$1
theEdges=$2
echo "<html>" >${outNetworkFlowFile}
echo "<head>" >>${outNetworkFlowFile}
echo "    <script type=\"text/javascript\" src=\"https://unpkg.com/vis-network/standalone/umd/vis-network.min.js\"></script>" >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "    <style type=\"text/css\">" >>${outNetworkFlowFile}
echo "        #sgnetwork {" >>${outNetworkFlowFile}
echo "            width: 1200px;" >>${outNetworkFlowFile}
echo "            height: 600px;" >>${outNetworkFlowFile}
echo "            border: 1px solid lightgray;" >>${outNetworkFlowFile}
echo "        }" >>${outNetworkFlowFile}
echo "    </style>" >>${outNetworkFlowFile}
echo "</head>" >>${outNetworkFlowFile}
echo "<body>" >>${outNetworkFlowFile}
echo "<div id=\"sgnetwork\"></div> " >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "<script type=\"text/javascript\">" >>${outNetworkFlowFile}
echo "    // create an array with nodes" >>${outNetworkFlowFile}
echo "    var nodes = new vis.DataSet(${theNodes});" >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "    // create an array with edges" >>${outNetworkFlowFile}
echo "    var edges = new vis.DataSet(${theEdges});" >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "    // create a network" >>${outNetworkFlowFile}
echo "    var container = document.getElementById('sgnetwork');" >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "    // provide the data in the vis format" >>${outNetworkFlowFile}
echo "    var data = {" >>${outNetworkFlowFile}
echo "        nodes: nodes," >>${outNetworkFlowFile}
echo "        edges: edges" >>${outNetworkFlowFile}
echo "    };" >>${outNetworkFlowFile}
echo "    var options = {autoResize: true, " >>${outNetworkFlowFile}
echo "                   height: '100%', " >>${outNetworkFlowFile}
echo "                   width: '100%', " >>${outNetworkFlowFile}
echo "                   clickToUse: true, " >>${outNetworkFlowFile}
echo "                   configure: {enabled: true, filter: 'nodes,edges', showButton: true}," >>${outNetworkFlowFile}
echo "                   \"nodes\": {\"physics\": true, \"shape\": \"box\" }," >>${outNetworkFlowFile}
echo "                   edges: { \"arrows\": {\"from\": {\"enabled\": true, \"scaleFactor\": 0.25}},\"dashes\": false, \"font\": {\"align\": \"middle\"},\"physics\": true}" >>${outNetworkFlowFile} 
echo "                  };" >>${outNetworkFlowFile}
echo "" >>${outNetworkFlowFile}
echo "    var network = new vis.Network(container, data, options);" >>${outNetworkFlowFile}
echo "</script>" >>${outNetworkFlowFile}
echo "</body>" >>${outNetworkFlowFile}
echo "</html>" >>${outNetworkFlowFile}

}
getEdgeItemsFromUserIdGroupPairs () {
    sgDescriptionJson=$1
    result=""
    #inbound items
    result="${result}$(echo ${sgDescriptionJson}|jq -c '{from: .GroupId, to:.IpPermissions[].UserIdGroupPairs[].GroupId}'|sort -u)"
    #outbound items
    result="${result}$(echo ${sgDescriptionJson}|jq -c '{from:.IpPermissionsEgress[].UserIdGroupPairs[].GroupId, to: .GroupId}'|sort -u)"
    echo ${result}
}
getEdgeItemsWithLabelFromUserIdGroupPairs () {
    sgDescriptionJson=$1
    result=""
    #inbound items
    result=${result}$(echo ${sgDescriptionJson}|jq -c '{from: .GroupId, to:.IpPermissions[].UserIdGroupPairs[].GroupId, label: ((.IpPermissions[].ToPort|tostring) +"/"+ .IpPermissions[].IpProtocol)}'|sort -u)
    #outbound items
    result=${result}$(echo ${sgDescriptionJson}|jq -c '{from:.IpPermissionsEgress[].UserIdGroupPairs[].GroupId, to: .GroupId, label: ((.IpPermissions[].ToPort|tostring)+"/"+ .IpPermissions[].IpProtocol)}'|sort -u)
    echo ${result}
}
getEdgeItemsFromIpRanges () {
    sgDescriptionJson=$1
    result=""
    result="${result}$(echo ${sgDescriptionJson}|jq -c '{from: .GroupId, to:.IpPermissions[].IpRanges[].CidrIp}'|sort -u)"
    
    echo ${result}
}

getEdgeItemsWithLabelFromIpRanges () {
    sgDescriptionJson=$1
    result=""
    result="${result}$(echo ${sgDescriptionJson}|jq -c '{from: .GroupId, to:.IpPermissions[].IpRanges[].CidrIp, label: ((.IpPermissions[].ToPort|tostring) +"/"+ .IpPermissions[].IpProtocol)}'|sort -u)"
    
    echo ${result}
}
getNodeItems () {
    result=""
    result=$(cat ${describeSgJsonFile}|jq -c '.SecurityGroups[]|{id: .GroupId, label: .GroupName}'|sort -u)
    result="${result}$(cat ${describeSgJsonFile}|jq -c '.SecurityGroups[]| .IpPermissions[].IpRanges[]|{id: .CidrIp, label: .CidrIp}'|sort -u)"
    result="${result}$(cat ${describeSgJsonFile}|jq -c .SecurityGroups[]|grep "VpcPeeringConnectionId"|jq -c .IpPermissions[].UserIdGroupPairs[]|grep VpcPeeringConnectionId|jq '{id: .GroupId, label: (.GroupId + "/"+ .UserId +"/vpcPeering")}'|jq -c|sort -u)"
#    result="${result}$(cat ${describeSgJsonFile}|jq -c .SecurityGroups[]|grep "VpcPeeringConnectionId"|jq -c .IpPermissions[].UserIdGroupPairs[]|grep VpcPeeringConnectionId|jq '{id: .GroupId, label: (.UserId +"/"+ .Description)}'|jq -c|sort -u)"
    
    echo ${result}
}

createNodesEdgesJson () {
    nodes=$1
    edges=$2
    #use temp files to get around jq's Argument list too long exception for large describeSgJsonFile.  the work around to replace below commented out line
    #jq -n --argjson nodes "$(echo ${nodes}|jq -s)" --argjson edges "$(echo ${edges}|jq -s)" '$ARGS.named'> ${nodesEdgesJsonFile}

    nodeListFile="/tmp/nodeList.json"
    edgeListFile="/tmp/edgeList.json"
    echo "    generating ${nodesEdgesJsonFile} .... "
    echo ${nodes}|jq -s > ${nodeListFile}
    echo ${edges}|jq -s > ${edgeListFile}
    jq -n --slurpfile nodes ${nodeListFile} --slurpfile edges ${edgeListFile} '$ARGS.named' > ${nodesEdgesJsonFile}
    
}

# ======
# main
# ======
describeSgJsonFile=$1
outNetworkFlowFile=$2
edgeLabelFlag=$3

if [ -z "${describeSgJsonFile}" ] || [ -z "${outNetworkFlowFile}" ]
then
    echo "usage: $0 <describeSgJsonFile> <outNetworkFlowFile> [edgeLabelFlag=true|false, default=true]"
    echo "    eg: $0 /path/to/aws-ec2-describe-security-groups-output-file.json /tmp/to-be-created-security-groups-networking-web-page.html"
    exit 1
fi

nodesEdgesJsonFile=${describeSgJsonFile}.nodes.edges.json
nodeItems=$(getNodeItems)

echo ""
#echo "Nodes list:"
nodesList=$(cat ${describeSgJsonFile}|jq .SecurityGroups[].GroupName|sed -e 's#"##g')
#echo "${nodesList}"

edgeItems=""
numSg=0
for n in ${nodesList}
do
    echo "    extracting edges items for ${n} ...."
    nData=$(cat ${describeSgJsonFile}|jq -c .SecurityGroups[] |grep "\"GroupName\":\"${n}\"") 
    if [ "${edgeLabelFlag}" != "false" ]
    then
        edgeItems=${edgeItems}$(getEdgeItemsWithLabelFromUserIdGroupPairs "${nData}")
        edgeItems=${edgeItems}$(getEdgeItemsWithLabelFromIpRanges "${nData}")
    else
        edgeItems=${edgeItems}$(getEdgeItemsFromUserIdGroupPairs "${nData}")
        edgeItems=${edgeItems}$(getEdgeItemsFromIpRanges "${nData}")
    fi
    numSg=$(expr ${numSg} + 1)
done
echo "    processed ${numSg} GroupName in ${describeSgJsonFile}."
echo ""

createNodesEdgesJson "${nodeItems}" "${edgeItems}"

echo ""
nodeData=$(cat ${nodesEdgesJsonFile}|jq -c .nodes[][]|sort -u|jq -s -c)
edgeData=$(cat ${nodesEdgesJsonFile}|jq -c .edges[][]|sort -u|jq -s -c)
echo "         input file: ${describeSgJsonFile}"
echo "        output file: ${outNetworkFlowFile}"
if [ "${edgeLabelFlag}" == "false" ]
then
    echo "      edgeLabelFlag: ${edgeLabelFlag}"
else
    echo "      edgeLabelFlag: true"
fi
echo "    number of nodes: $(cat ${nodesEdgesJsonFile}|jq -c .nodes[][]|sort -u|wc -l)"
echo "    number of edges: $(cat ${nodesEdgesJsonFile}|jq -c .edges[][]|sort -u|wc -l)"

createHtmlNetworkFlowDiagram "${nodeData}" "${edgeData}"

echo ""
echo ""
