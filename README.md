# Trainline


## Usage

Inside the repo folder
```bash
$ irb
```

```ruby
require_relative  'com_thetrainline'

ComThetrainline.find('Berlin', 'Paris', DateTime.now)

[
  { 
    :departure_station=>"Berlin Hbf",
    :departure_at=>#<DateTime: 2024-07-14T04:29:00+00:00 ((2460506j,16140s,0n),+0s,2299161j)>,
    :arrival_station=>"Paris Gare de l’Est",
    :arrival_at=>#<DateTime: 2024-07-14T12:52:00+00:00 ((2460506j,46320s,0n),+0s,2299161j)>,
    :service_agencies=>["Deutsche Bahn"],
    :duration_in_minutes=>503.0,
    :changeovers=>1,
    :products=>["train"],
    :fares=> [
      {:name=>"Super Sparpreis Europa", :currency=>"EUR", :price_in_cents=>132.9, :comfort_class=>"Standard"},
      {:name=>"Sparpreis Europa", :currency=>"EUR", :price_in_cents=>143.9, :comfort_class=>"Standard"},
      {:name=>"Flexpreis Europa", :currency=>"EUR", :price_in_cents=>233.0, :comfort_class=>"Standard"},
      {:name=>"Super Sparpreis Europa", :currency=>"EUR", :price_in_cents=>153.9, :comfort_class=>"First"},
      {:name=>"Sparpreis Europa", :currency=>"EUR", :price_in_cents=>168.9, :comfort_class=>"First"},
      {:name=>"Flexpreis Europa", :currency=>"EUR", :price_in_cents=>384.0, :comfort_class=>"First"}
    ]
  },
  # ...and other similar segments
]
```

## The API structure
<img width="1170" alt="Screenshot 2024-07-09 at 14 17 04" src="https://github.com/ssvignesh24/trainlane/assets/12658419/605b4273-c40d-48f4-bfc4-9c7bafce0b74">


The Trainline API response follows a pattern similar to JSON:API where each entity's details are independently described and their relation is indicated using their ID/URI. This is in contrast to nesting the related fields.

The main components of the response are,

`journey` Holds the high-level information of each option, like, legs, time, duration, etc

`section`  Each journey consists of one or more sections. A section can have a single leg or multiple legs. A group of legs is considered as one section when the operating carrier is the same e.g., Deutsche Bahn

`alternatives` An alternative is an option given for a ticket in a section. Alternatives differ by class, comfort, and flexibility. A section can have one or more alternatives for different classes and flexibilities

## Assumptions
1. Trainline has three flexibility options, namely, `nonflexi`, `semiflexi` and `flexi`
2. Bus tickets does not have first class tickets - only standard-semiflexi ticket
3. If an alternative has more than one fare, I picked the first one to match the price shown in the segment
4. In the result, the `service_agencies` are the transport companies e.g., DB. But if you mean booking system as `service_agencies` then    `thetrainline` should be hard-coded for this test.
5. The `fares->name` in the result is the comfort name
6. The `fares->comfort_class` in the result is `1` but Trainline does not provide a number for class names, it has `Standard` and `First class` classes. So I added the actual name instead of a number. But if that was intentional, we can map it to a number. I commented the logic [here](https://github.com/ssvignesh24/trainlane/blob/main/models/journey.rb#L63).

## Sample response in the repository
<img width="1177" alt="Screenshot 2024-07-09 at 20 46 36" src="https://github.com/ssvignesh24/trainlane/assets/12658419/d8dc6ddc-cc5c-4842-8538-6b66951f6416">
