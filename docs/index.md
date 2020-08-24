#Introduction
Tiller is a tool that generates configuration files. It takes a set of templates, fills them in with values from a variety of sources (such as environment variables, Consul, YAML files, JSON from a webservice...), installs them in a specified location and then optionally spawns a child process.

You might find this particularly useful if you're using Docker, as you can ship a set of configuration files for different environments inside one container, and/or easily build "parameterized containers" which users can then configure at runtime. 

However, its use is not just limited to Docker; you may also find it useful as a sort of "proxy" that can provide values to application configuration files from a data source that the application does not natively support. 

# Background and motivation
I had a number of Docker containers that I wanted to run with a slightly different configuration, depending on the environment I was launching them. For example, a web application might connect to a different database in a staging environment, a MongoDB replica set name might be different, or I might want to allocate a different amount of memory to a Java process. This meant my options basically looked like:

* Maintain multiple containers / Dockerfiles.
* Maintain the configuration in separate data volumes and use --volumes-from to pull the relevant container in.
* Bundle the configuration files into one container, and manually specify the `CMD` or `ENTRYPOINT` values to pick this up. 

None of those really appealed due to duplication, or the complexity of an approach that would necessitate really long `docker run` commands. 

So I knocked up a quick Ruby script (originally called "Runner.rb") that I could use across all my containers, which does the following :

* Generates configuration files from ERB templates (which can come from a number of sources)
* Uses values provided from a data source (i.e YAML files) for each environment
* Copies the generated templates to the correct location and specifies permissions
* Optionally executes a child process once it's finished (e.g. mongod, nginx, supervisord, etc.)
* Now provides a pluggable architecture, so you can define additional data or template sources. For example, you can create a DataSource that looks up values from an LDAP store, or a TemplateSource that pulls things from a database. 

This way I can keep all my configuration together in the container, and just tell Docker which environment to use when I start it. I can also use it to dynamically alter configuration at runtime ("parameterized containers") by passing in configuration from environment variables, external files, or a datastore such as Consul. 

# Why "Tiller" ?
Docker-related projects all seem to have shipyard-related names, and this was the first ship-building related term I could find that didn't have an existing gem or project named after it! And a tiller is the thing that steers a boat, so it sounded appropriate for something that generates configuration files. And no, it's got nothing to do with the Helm package manager, I picked the name before that was a "thing" ;)

# Status

OK, real talk here. This project has more-or-less stalled. I hesitate to say "abandoned" because I still care about it, but I have to be honest with anyone who might be looking at using it. The thing is, my life has had a number of (positive!) changes recently such as becoming a Dad, which have led to my free project time being greatly reduced. 

Also, due to job changes and the changing technology landscape I now find myself involved in, I haven't actually used Tiller for several years. On top of that, I have realised that there are several fundamental issues with Tiller that I should tackle: Things like a re-write in Golang to avoid having to drag in a full Ruby/Gem environment for the runtime, and I also now believe that the top-level construct should be the file, and not the template that generates it. This would mean, for example, that having multiple files generated from the same template would be a very simple operation. The problem with all that is again lack of time, and the fact that I _really_ hate Go as a programming language.

So where does this leave the project ? Well, it _does_ work and has been battle-tested over many years. Some of the extra plugins such as Consul have badly stagnated however, and no longer work with current versions of libraries/APIs. If it works for you, then great! If you're looking for updates and a fancy Tiller 2.0 then I'm afraid you're going to be kept waiting. I'm not going to say "never" because I do still have a lot of love for this project; it was the first real open-source project I made that attracted a bunch of users, contributions and a small community around it which I'll always be thankful for. 

But I guess it's best for everyone if you consider it "done" and what you see is what you get. If anyone is interested in forking it and producing a "Tiller - The Next Generation" then by all means give me a shout and I'll update things with links and pointers to your project but I won't be transferring ownership/RubyGems.org ownership etc. in the interests of security.

Thanks again for everything, and stay safe out there.

-Mark Dastmalchi-Round, August 2020