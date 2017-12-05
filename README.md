# Auctioning

Basic workflow description:
Admin schedules an auction using /admin/auctions endpoint.
Here we determine when auction should start besides other params setting.
Scheduling algorithm works in the following way:
- define the limits in which auction can be scheduled (_from_ and _to_). _From_ is initialized as a current server time, _to_ is (ride at - 1.hour). But we also adjust these timestamps depending on drivers' active hours, please see the  [specs](https://github.com/sdzyba/auctioning-api/blob/master/spec/services/scheduling/resolver_spec.rb#L132)
- select all existing occupied time slots in _from_.._to_ range. If there are no occupied slots, just schedule the auction at the middle of _from_.._to_ range.
- if there are occupied slots, split them into two pieces: before the _middle_ point of _from_.._to_ range and after _middle_ point.
- find possible _after_middle_ and _before_middle_ slots. We do this by defining all possible slots with a _current_step_ and then we choose closest to the _middle_ point by substracting a difference between _occupied_after_/_occupied_before_ and _all_after_/_all_before_ and a getting _first_after_/_first_before_. Please see the  [specs](https://github.com/sdzyba/auctioning-api/blob/master/spec/services/scheduling/resolver_spec.rb#L16)
- is there are no slots available, divide the _current_step_ (default is 60 seconds) by 2 and iterate again. Please see the  [specs](https://github.com/sdzyba/auctioning-api/blob/master/spec/services/scheduling/resolver_spec.rb#L90)
- when starting time is determinated we persist an auction and schedule the StartAuctionWorker to Sidekiq on when the auction should start.
- _start_at_ calculation is locked by it's own separate lock (so we don't lock the entire auctions table) since we need to ensure the consistency of time slots.

StartAuctionWorker switches the auction status to _started_ so when drivers are requesting the list of auctions they only the started ones. Also this worker schedules AuctionStepWorker, which would switch the price and reschedule itself on a _next_step_ time. AuctionStepWorker would also switch the auction status to _finished_ once auction's steps have reached the limit (steps limit and steps count in general are calculated based on auction's _end_at_ - _start_at_). Here's [specs](https://github.com/sdzyba/auctioning-api/blob/master/spec/workers/auction_step_worker_spec.rb)

When driver wants to "pick up" and auction he sends a corresponding request. During this request processing we lock the auction record and assign it to driver. If there were multiple simultenious requests for the same auction, first one would be assigned and the rest of the requests would have an error response with "Already assigned" message.

#### Possible alternatives
- Dynamically change _start_at_ for each auction on every new auction arrival. A draft on how this could be implemented is [here](https://github.com/sdzyba/auctioning-api/blob/master/lib/dynamic_resolver.rb). Basically it's just selects all the slots, sorts them by priority (urgency) and reschedules them to be started as earlier as possible. While this solution sounds flexible, this flexibility brings another problems like not being able to "reschedule" anything in Sidekiq. So it'd either require some hacks to get it's working or just not to use Sidekiq at all and implement some separate listener process.
- Do not schedule auctions in a "blind" way but measure the market load on each piece of a timeline. This might be achived by using some counters, I guess, like redis' counters, but I didn't dive into this solution enough.

# Requirements

Build a small Ruby API / micro-service with a JSON or GRPC over HTTP interface to encapsulate an auctioning mechanism.

When a customer books a ride over Blacklane, we auction this ride to our network of drivers. Ideally we try to obtain the lowest price possible.

The auction can be triggered any time between the *time of the booking* and the *time of the ride*. The exact time an auction starts should be determined based on the following points:

- the ride is assigned to a driver as soon as possible
- drivers are active (assuming drivers check their phones between 8:00 and 20:00 every day)
- there aren't so many auctions running at the same time - the market is not flooded with offers
- $$$
- anything else you find useful

The auction price starts with the *lowest offering price* (10% of customer price) and increases gradually with time - until it's accepted by a driver or when the offering price reaches customer price (breaking even). Every price increase in the auction's lifetime is called an *auction step*. All auction steps are available over the same period of time and provide the same price increase (time & price advance is linear).

Auctions should run over a *short period of time* (e.g. 30 minutes) and *amount of steps* (e.g. 5 steps). You can make these values configurable (but don't have to).

### Endpoints

1. As a Blacklane admin, create the auction.

  Input:
  - customer price / break even price
  - time of ride / deadline
  - anything else you find useful

  Output:
  - auction ID
  - auction start time
  - auction end time
  - auction initial price
  - auction final price

2. As a driver, get a list of all the running auctions.

  Output:
  - auction ID
  - auction step price
  - auction step expiry time (how long is the price available)

3. As a driver, accept an auction.

  Input:
  - auction ID
  - driver ID
  - anything else you find useful

  Output:
  - some successful status code or error code with message

You can ignore authorization.

### Guidelines

- Preferred frameworks: any (e.g. Sinatra, Hobbit, Rails, Rack).
- Preferred data storage: any (e.g. MySQL, Postgres, Redis).
- Unit tests for the auctioning algorithms or the API interface (e.g. RSpec, Minitest)
- These are just guidelines. You can take these tasks in any direction you want as long as it makes sense to you. Have fun!

