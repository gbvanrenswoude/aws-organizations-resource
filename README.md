AWS Organization Concourse resource
=============
This resource will check AWS Organizations for updates/changes.   
The `in` command will output all accounts from the Organizations.
The `check` command will generate hashes.
The `out` command is a dud for now.

Basic Concourse structure:  
`/opt/resource/check`: checking for new versions of the resource  
`/opt/resource/in`: pulling a version of the resource down  
`/opt/resource/out`: idempotently pushing a version up  

Implementation is mvpish

## Parameters

### Required parameters
- `organization_account` The accountnumber of the account where the organization is placed. This parameter will be used to access the organizations information. Value should be for example `255181513171`.
- `assumerole` The role that the resource will use to look up data in the organizations account. A session will be made using the assumerole value and the organization_account value. Value should be the friendly name of the role, for example `myreadonlyrole`.

### Optional parameters
- `active` Set to `true` or `True` if you want only active accounts to be be used in the check or to be returned in the organization list. Any other value or no value specified will result in the default `false`.
- `rolename` An optional parameter to return an assumable role arn per account to use in your jobs or tasks later on. If used, specify the friendly role name, for example `myassumetoaccountrole`. You can access the assumeable role arn via the `role:` key in the returned list, per account.
- `scope` An optional parameter to return only the accounts under a given path or multiple paths. A path is made up of the friendly ou names (for example `/mycompany/prod`). Specify multiple paths using a json list; `["/mycompany/prod","/myothercompany/prod"]`. Defaults to the root (/).

## Organization path
In order to generate a tree that caters to multiple usecases, instead of a tree the list returned makes use of paths. Every account returned has the path key, that contains a list of all paths the account is member of in the organization.
A path is made up of the friendly names of the organizations ou's. Root is `/`.

For example, if you have an ou called mycompany and under this ou 3 other ou's, called prod, dev and unmanaged, you can return only the accounts for the prod and dev ou by querying out the organization paths `["/mycompany/prod","/mycompany/dev"]` via the optional scope parameter. In the returned list, the accounts will be member of 2 paths, for example /mycompany and /mycompany/prod. This allows you fancy usecases, like making your jobs aware of the split between production and development accounts.

## Example usage
### Resource_type
Define the `resource_type`:
```yaml
resource_types:
- name: aws-organizations-resource
  type: docker-image
  source:
    repository: myregistry/docker-aws-organizations-resource-master
    tag: 1.0
```
And use it to define the `resource`:
```yaml
resources:
- name: organizations
  type: nn-organizations
  source:
    active: true                       
    scope: ["/mycompany/prod","/myothercompany/prod"]                       
    organization_account: 223114181718  
```

### Outputs
The resource will output a file:  
`account.yml`: This contains a YML with a list of accounts in the scope and their paths.  
```yml
accounts:
- account_id: '110114130110'
  email: somemail@something.com
  name: Brownie Account
  paths:
  - path:/browniecompany
  - path:/browniecompany/unmanagedaccounts
  role: arn:aws:iam::110114130110:role/pipelineadmin
- account_id: '944444444353'
  email: officekattem@something.com
  name: Account for team in Kattem
  paths:
  - path:/kattem
  - path:/kattem/production
  role: arn:aws:iam::944444444353:role/pipelineadmin
```  

## How to run locally
To run the `check` or `in` commands locally, use:
```shell
cat sample_input.json | ./in './'
cat sample_input.json | ./in './' 2> /dev/null
```
This will create the output files in your current directory.

and check
```shell
cat sample_input.json | ./check
cat sample_input.json | ./check 2> /dev/null
```

Make sure you have python3 and your dependencies installed if you run the code directly and not via the Docker image.

Thank you.
