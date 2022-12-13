Contributing to the PiNanas project
===================================

Test PiNanas on new harware / now OSes
--------------------------------------

If you happen to test PiNanas on architectures or OSes not listed in [INSTALL](INSTALL.md "docs/INSTALL.md"), please
report your findings. You can either do a [Pull Request](#create-a-pull-request) to update PiNanas' documentation, or
open an issue as if it was a "bug" of documentation. See [Report issues](#report-issues-bug-request-features-).


Report issues, bug, request features, ...
-----------------------------------------

Please report issues and bug, suggest new features, share success when testing new hardware or OSes, by [opening an _Issue_](https://github.com/yscialom/pinanas/issues/new/choose) on PiNanas Github repository.


Improve PiNanas
---------------

### Get the PiNanas project

#### Prerequisites
To contribute to project, you will need to install on your computer [Git](https://git-scm.com/) and to have a [Github
account](https://github.com/join?source=header-home).

If you don't really know how to use git, I will recommend you to check this
[guide](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics). If you are comfortable with git and GitHub, just
go to "Create a pull request" section.

##### How to configure Git
Associate your GitHub account and your local git configuration:

- Set up your name: `git config --global user.name "Firstname lastname"`
- Set up your e-mail address: `git config --global user.email "email@example.com"`

##### Get the project on your GitHub account
You have to click on the fork button of the [PiNanas GitHub](https://github.com/yscialom/pinanas).

![Github: Fork a repository](res/github-forking.png)

##### Get your forked project on your computer
Go where you want to work on the project (for example in your home directory) and enter this command (don't forget to
replace `username` with your GitHub username):
```
git clone https://github.com/username/pinanas
```


#### Create a branch
To avoid conflicts when updating your fork from the upstream, always work on a branch (from `develop`):
```
git checkout develop
git checkout -b feature/42-make-coffee
```
We recommend explicit name for your branch, such as `feature/<id>-<short-description>`.

Now, you can work on your new branch. Modify code, test your changes and commit locally.

Update your GitHub repository:
```
git push origin feature/42-make-coffee
```


### Create a pull request

On GitHub you should see your freshly-pushed branch (with commits):

![Github: creating a Pull request](res/github-creating-a-pull-request.png)

Click the "Compare & pull request" button, you will be prompted for a name for your pull request (PR).

![Github: example of issue](res/github-issue.png)

Example name of a pull request: `Issue 42: make coffee`

If you forget something, don't worry: you can continue to push commits on your branch and it will automatically update your pull request.

Now the PiNanas team can review your pull request... and merge it! If need be, do @ping the team.

Thank you for your time, interest and effort :)

#### Tips

##### #1

If you had to update your fork because there is activity on the upstream, you can go to this link:
[syncing a fork](https://help.github.com/articles/syncing-a-fork/ "Github documentation").

##### #2

When you finished your work and about to commit the final change, you can specify *Fixes* and the GitHub id of the original issue to help the Piwigo team. This will close automatically the pull request when this will be merged on the upstream.

Example of a last commit: `Fixes #42 Make coffee`.
