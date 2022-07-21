# The Kisi Backend Code Challenge

This repository can be used as a starting point for the Kisi Backend Code Challenge. Feel free to replace this `README.md` with your own when you submit your solution.

This repository contains:
- A bare-bones Rails 6 API app with a `Gemfile` that contains the neccessary libraries for the project.
- A configured adapter ([lib/active_job/queue_adapters/pubsub_adapter.rb](lib/active_job/queue_adapters/pubsub_adapter.rb)) to enqueue jobs. Use as a starting point for your own code.
- A rake task ([lib/tasks/worker.rake](lib/tasks/worker.rake)) to launch the worker process. Use as a starting point for your own code.
- A class ([lib/pubsub.rb](lib/pubsub.rb)) that wraps the GCP Pub/Sub client. Use as as a starting point for your own code.
- A [Dockerfile](Dockerfile) and a [docker-compose.yml](docker-compose.yml) configured to spin up necessary services (web server, worker, pub/sub emulator).

# Pubsub

  Google Cloud Pub/Sub adapter and worker for ActiveJob

## Configuration

### Adapter
First, change the ActiveJob backend.

``` ruby
Rails.application.config.active_job.queue_adapter = :pubsub
```

## Usage

To boot up the background jobs server, you first need to export your google cloud configuration file to your environment:

    $ export GOOGLE_APPLICATION_CREDENTIALS=/path/to/config/file
Note: The Google cloud entity(service account, user, e.t.c) in the config must have top-level permissions for google pub/sub (owner or admin). He/She/It should be able to read/delete/create Pub/Sub resources).

With that ActiveJob would use the pubsueque adapter to enqueue jobs to Google pub/sub and execute them immediately or at a specified time.

```ruby
  class HelloJob < ActiveJob::Base
        def perform(args)
            // job
        end
    end

    HelloJob.perform_later(args) # enqueue the job to pub/sub and execute in the background immediately (after the pub/sub subscriber receives the job).
    HelloJob.set(wait_until: 10.minutes).perform_later(args) # enqueue the job to pub/sub and execute in 10 minutes.
```

## Rake task
 The rake task can be run from the command line using the following command. This task pulls messages from GCP Pub/Sub and executes the corresponding job.

 ```ruby
   bundle exec rake worker:run
 ```

 ## Enqueue a Job
 ```ruby
  HelloJob.perform_later(args) # enqueue the job to pub/sub and execute in the background immediately (after the pub/sub subscriber receives the job).
  HelloJob.set(wait_until: 10.minutes).perform_later(args) # enqueue the job to pub/sub and execute in 10 minutes.
 ```

## Testing

## Using Docker
To start all services, make sure you have [Docker](https://www.docker.com/products/docker-desktop/) installed and run:
```
$ docker compose up
```

To restart the worker, i.e. after a code change:
```
$ docker compose restart worker
```

To start a console:
```
$ docker compose run --rm web bin/rails console
```

If you run docker with a VM (e.g. Docker Desktop for Mac) we recommend you allocate at least 2GB Memory

## Using Pub/Sub emulator

In order to test the worker in your local environment, it is a good idea to use the Pub/Sub emulator provided by gcloud command. Refer to <a href="https://cloud.google.com/pubsub/docs/emulator" target="_blank">this</a>document for the installation procedure.

```
$ gcloud beta emulators pubsub start --project=PUBSUB_PROJECT_ID  #starts the emulator

(Switch to another terminal)

$(gcloud beta emulators pubsub env-init) #setting environment variables

To use the emulator, you must have an application built using the Cloud Client Libraries
