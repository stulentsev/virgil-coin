### How to use


You need ruby 2.4.2 (or any recent ruby should do).

Install missing gems

```
bundle install
```

Then start the poller

    ruby main.rb


### Strategy

Sorts the available units by their cost-benefit ratio then waits and buys the best one.

Example output:

```
+------------+---------------+--------+----------------------+
| Unit Type  | Cost Per Coin | + rate | When can buy?        |
+------------+---------------+--------+----------------------+
| Geforce    | 128           | 64     | in 716 seconds       |
| Radeon     | 147           | 8      | in 23 seconds        |
| Manual     | 152           | 0.125  | NOW                  |
| Intel      | 170           | 1      | NOW                  |
| Asic       | 512           | 256    | in 12852 seconds     |
| Farm       | 512           | 2048   | in 103470 seconds    |
| Factory    | 2048          | 8192   | in 1656916 seconds   |
| DataCenter | 4096          | 65536  | in 26512050 seconds  |
| Cloud      | 16384         | 262144 | in 424194208 seconds |
+------------+---------------+--------+----------------------+
```

### Bonus

Leaderboard analyzer. Tracks movements in the leaderboard. Can support decision making (should
I buy more hardware or the victory is assured?)

Example output:

```
+-------+---------------+--------------+----------------+---------------------+------------+
| place | user id       | wealth       | distance       | distance change/sec | time to ps |
+-------+---------------+--------------+----------------+---------------------+------------+
| 3     | 5010200053289 | 109156150102 | 2.8 billion    | -265.2 thousands    | 13:34:10   |
| 4     | ME!           | 106333531772 | -              | -                   | 14:16:08   |
| 5     | 4623010419383 | 105837296728 | -496.2 million | 34.8 thousands      | 14:34:39   |
| 14    | 4897520092231 | 91689417810  | -14.6 billion  | -697.5 thousands    | 14:40:05   |
| 1     | 4952450120524 | 112939397886 | 6.6 billion    | 317.9 thousands     | 14:41:54   |
| 8     | 4922790454981 | 99745884942  | -6.6 billion   | 91.6 thousands      | 15:06:13   |
| 10    | 4895470030560 | 93808782377  | -12.5 billion  | -156.9 thousands    | 15:10:42   |
| 2     | 4925940044431 | 109831341362 | 3.5 billion    | 721.5 thousands     | 15:43:22   |
| 15    | 4908660584072 | 88961160248  | -17.4 billion  | 20.9 thousands      | 15:49:09   |
| 6     | 4947210014295 | 103448801272 | -2.9 billion   | 703.9 thousands     | 15:50:17   |
| 19    | 4964530075177 | 79586237944  | -26.7 billion  | -1.3 million        | 15:51:20   |
| 13    | 4964460347519 | 92159079058  | -14.2 billion  | 162.1 thousands     | 15:57:36   |
| 9     | 3220012333666 | 97811217474  | -8.5 billion   | 566.9 thousands     | 16:01:49   |
| 20    | 4956750072239 | 79050856356  | -27.3 billion  | -859.2 thousands    | 16:01:54   |
| 12    | 4884910426567 | 92255281862  | -14.1 billion  | 409.4 thousands     | 16:09:16   |
| 17    | 4624492010743 | 85072661405  | -21.3 billion  | 26.6 thousands      | 16:11:33   |
| 18    | 4925049932128 | 84171580639  | -22.2 billion  | -3.8 thousands      | 16:12:55   |
| 11    | 4993540411777 | 93141439313  | -13.2 billion  | 461.9 thousands     | 16:12:58   |
| 7     | 4921710167720 | 100701382574 | -5.6 billion   | 522.8 thousands     | 16:17:24   |
| 16    | 4884870170519 | 85187281291  | -21.1 billion  | 336.9 thousands     | 16:34:13   |
| 21    | 4967660517028 | 71358953868  | -35.0 billion  | -391.2 thousands    | 17:19:12   |
| 23    | 4770490166172 | 64366389535  | -42.0 billion  | -698.0 thousands    | 17:40:03   |
| 22    | 4915100366895 | 64587182357  | -41.7 billion  | -226.5 thousands    | 18:00:09   |
| 24    | 4884910018010 | 62331564256  | -44.0 billion  | -210.6 thousands    | 18:04:36   |
| 25    | 4884870226609 | 60488621832  | -45.8 billion  | -472.3 thousands    | 18:08:23   |
+-------+---------------+--------------+----------------+---------------------+------------+
```
