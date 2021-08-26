import json
import boto3


def lambda_handler(event, context):
    result = revoke_security_group_ingress(event['detail'])
    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }


def revoke_security_group_ingress(event_detail):
    request_parameters = event_detail['requestParameters']

    ip_permissions_to_add, ip_permissions_to_revoke = get_vulnerable_ingress_rules(
        request_parameters['ipPermissions']['items'])
    print('ip permissions to revoke')
    print(ip_permissions_to_revoke)
    print('ip permissions to add')
    print(ip_permissions_to_add)
    if len(ip_permissions_to_revoke) > 0:
        response = boto3.client('ec2').revoke_security_group_ingress(
            GroupId=request_parameters['groupId'],
            IpPermissions=ip_permissions_to_revoke
        )
        response = boto3.client('ec2').authorize_security_group_ingress(
            GroupId=request_parameters['groupId'],
            IpPermissions=ip_permissions_to_add
        )
    # Build the result
    result = {}
    result['group_id'] = request_parameters['groupId']
    result['user_name'] = event_detail['userIdentity']['arn']
    result['ip_permissions'] = ip_permissions_to_revoke

    return result


def get_vulnerable_ingress_rules(ip_items):
    new_ip_items = []
    vulnerable_ip_items = []
    for ip_item in ip_items:

        new_ip_item = {
            "IpProtocol": ip_item['ipProtocol'],
            "FromPort": ip_item['fromPort'],
            "ToPort": ip_item['toPort']
        }
        vulnerable_ip_item = {
            "IpProtocol": ip_item['ipProtocol'],
            "FromPort": ip_item['fromPort'],
            "ToPort": ip_item['toPort']
        }

        # CidrIp or CidrIpv6 (IPv4 or IPv6)?
        if 'ipv6Ranges' in ip_item and ip_item['ipv6Ranges']:
            # This is an IPv6 permission range, so change the key names.
            ipv_range_list_name = 'ipv6Ranges'
            ipv_address_value = 'cidrIpv6'
            ipv_range_list_name_capitalized = 'Ipv6Ranges'
            ipv_address_value_capitalized = 'CidrIpv6'
        else:
            ipv_range_list_name = 'ipRanges'
            ipv_address_value = 'cidrIp'
            ipv_range_list_name_capitalized = 'IpRanges'
            ipv_address_value_capitalized = 'CidrIp'

        vulnerable_ip_ranges = []
        new_ip_ranges = []

        # Next, build the IP permission list.
        if 'items' in ip_item[ipv_range_list_name]:
            for item in ip_item[ipv_range_list_name]['items']:
                if (item[ipv_address_value] == '0.0.0.0/0' or item[ipv_address_value] == '::/0'):
                    vulnerable_ip_ranges.append({ipv_address_value_capitalized: item[ipv_address_value]})
                    new_ip_ranges.append({'CidrIp': "145.14.1.3/32"})

        if len(vulnerable_ip_ranges) > 0:
            vulnerable_ip_item[ipv_range_list_name_capitalized] = vulnerable_ip_ranges
            vulnerable_ip_items.append(vulnerable_ip_item)
            if not contains(new_ip_items, lambda nip_item: nip_item['FromPort'] == new_ip_item['FromPort']):
                new_ip_item['IpRanges'] = new_ip_ranges
                new_ip_items.append(new_ip_item)

    return new_ip_items, vulnerable_ip_items


def contains(list_to_find, filter):
    for x in list_to_find:
        if filter(x):
            return True
    return False
