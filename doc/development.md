## Running ZAT locally

If you want to run ZAT locally, one way to do this is to use the Docker image.

(This works around various issues associated to having certain Ruby versions installed on the host machine and other odds and ends.)

In particular, to run ZAT in this mode:

* Install Docker on your host machine.
* Clone the ZAT repository.
* Run the following command in the ZAT repository:

```
./scripts/compile.sh
```
This will build the Docker image for zat.
* Append scripts/invoke.sh to your PATH, or alternatively alias it in your .bashrc, .zshrc, or .profile.
* For example, if you were to append alias zt=/User/your_user/zat/scripts/invoke.sh to your .bashrc, you would be able to run zt to run ZAT locally.
```
>zt help new
Usage:
  zat new

Options:

Generate a new app
```