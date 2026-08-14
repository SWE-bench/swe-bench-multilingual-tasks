Hello,

Thanks for the report. The analysis is also correct, comparison of `CarbonInterval` is using `->totalMicroseconds` and it's being negative in this case:

```php
$diff = Carbon::now()->addDays(15)->diff(Carbon::now(), true);
var_dump($diff->totalMicroseconds, CarbonInterval::minutes(30)->totalMicroseconds);
```

=>
```
double(-1295999999048)
double(1800000000)
```

I will investigate further.

As a work-around in the meantime you can use `abs($interval->totalMicroseconds)` and compare them.