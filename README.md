# Using terraform to deploy a Icecream Cluster to DigitalOcean

Icecream is a distributed computing task scheduler designed for high-performance computing environments. With this project, you can quickly provision the necessary infrastructure and set up the Icecream cluster on DigitalOcean.

## Prerequisites

Before you begin, ensure that you have the following prerequisites set up:

1. A [DigitalOcean](https://www.digitalocean.com/) account. You will need create an [API Key](https://docs.digitalocean.com/reference/api/create-personal-access-token/) in the dashboard.
2. [Terraform](https://www.terraform.io/downloads.html) installed on your local machine.

## Account credentials

Generate ssh key pair with

```bash
ssh-keygen -f ssh-key -C "icecream@digitalocean"
```

Add the generated public key in DigitalOcean settings.

## Deployment Steps

To deploy the Icecream cluster, follow these steps:

1. Clone this repository to your local machine:

```bash
git clone https://github.com/santanamobile/do-icecream-cluster.git
```

2. Navigate to the project directory:

```bash
cd do-icecream-cluster
```

3. Initialize Terraform:

```bash
terraform init
```

4. Configure DigitalOcean API credentials:

   - Create a new file named `terraform.tfvars` in the project directory.
   - Add the following content to `terraform.tfvars`, replacing the values with your DigitalOcean API token:

```hcl
do_token = "YOUR_DIGITALOCEAN_API_TOKEN"
```

5. Review and customize the cluster configuration:

In the project directory, copy the file 'variables.tf.example' to 
'variables.tf'
Review the available variables and modify their values as needed.
For example, you can adjust the region, droplet count (number of workers), droplet size, , Digital Ocean ssh key name and token.

6. After the review, you'll be able to deploy the desired infrastructure to Digital Ocean cloud.

```bash
terraform plan -out=icecream.tfplan
```

6. Deploy the Icecream cluster:

```bash
terraform apply "icecream.tfplan"
```

7. Review the planned changes and confirm the deployment by entering `yes` when prompted.

Terraform will now provision the required DigitalOcean resources, including droplets, networks, and other dependencies. This step requires approximately 5 minutes to finish.

8. Once the deployment is complete, Terraform will output the IP addresses of the Icecream cluster control node and worker nodes. Make a note of these values as you will need them to connect and use the cluster.

With the Icecream scheduller and worker nodes up and running, you can ssh to the scheduler host and submit tasks to the cluster.

## Yocto Aspirations

This project is a start point of another project, a server cluster to build yocto artefacts.

## Cleaning Up

To remove the Icecream cluster and associated resources from DigitalOcean, run the following command in the project directory:

```bash
terraform destroy
```

Review the planned changes and enter `yes` to confirm the destruction of the resources.

Please note that this action cannot be undone, and all resources provisioned by Terraform will be permanently deleted.

## TODO

- Improve firewall rules.

## Contributing

Contributions to this project are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request.

## License

This project is licensed under the [MIT License](LICENSE). Feel free to modify and use it according to your needs.
