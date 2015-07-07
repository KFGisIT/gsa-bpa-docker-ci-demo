#Our Approach 
##Project
Our general approach for projects like this is to establish a project with 2-4 week agile sprints. 

The ideal project workflow starts with a problem as it is understood by a client and information is gathered around the parameters of the problem. As the problem comes to be well-understood by team members, the goals for the project take shape and agile sprints for development can begin. 

Before development really begins, some sprints can be undertaken with the client to establish project parameters and the approach for solving the problem.

Often, the approach to the problem and the scale of the problem dictate the constraints that the development team will face. For this particular project, the user stories have been abbreviated and the teams' experiences were drawn from to create a demonstration project

##Development 
The automation frameworks around testing and integration mean that there are several avenues available to developers for contributing to the project. The overall containerization of the project meant that small teams can work in a "sandbox" to develop new features for the site. 

Once the new feature reaches a certain level of maturity, the feature team can work with the team that has access to the "production" version of the site to integrate the new feature. Automation technologies mean that, for the staging team, copies of production data can be staged into the development site and integrated with new feature sets programmatically. 

The modular nature of Drupal, in this case, means that the front-end team can be working on the site theme, one or more teams can be working modules, functionality and data integration and the content team can be working on content on the staging site. Because the teams can work with only a loose association up until the point of integration, the project structure has lent itself to good parallelization in commercial and government sectors. 

##Automation
We are using [Travis-CI](https://travis-ci.org) for this project to demonstrate continuous integration and unit tests with PHPUnit. Though TUnit tests are also included in the project (for testing JSON feeds functionality), the open tier of [Travis-CI](https://travis-ci.org) does not fully support this. However, it is easy for developers to automate this testing on their own development machine and the DevOps master can manage this type of testing job via CRON, for example, easily. The Travis-CI links and build documentation are provided in the [README.md](README.md) and the test YML files are included in the Drupal Project repository.

The Dockerfiles provide further automation of a development/staging enviornment. These Dockerfiles can, for example, be extended to include TUnit testing that Travis-CI lacks. 

Sometimes, these types of tests are not enough. In those cases, we leverage Selenium for better browser automation testing. An example of this is included in the [Yuck.IO demonstration site](http://yuckio.kfgisit.com) that is plugged into the [OpenFDA Drupal Dataset Explorer website](http://openfda.kfgisit.com).


