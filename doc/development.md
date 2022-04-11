## Running ZAT locally

If you want to run ZAT locally, one way to do this is to use the Docker image.

(This works around various issues associated to having certain Ruby versions installed on the host machine and other odds and ends.)

In particular, to run ZAT in this mode:

* Install Docker on your host machine.
* Clone the ZAT repository.
* Run the following command in the ZAT repository:

```
./zat.sh
```
The first time this is run, this will check for the existence of the Docker image and build it if it doesn't exist.  It will then proceed to run the Docker image tagged "zat:latest".

You should then see a list of available commands.

For instance, you should be able to get this sort of output.

```
>./zat.sh help new
Usage:
  zat new

Options:

Generate a new app
```