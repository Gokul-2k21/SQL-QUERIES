;with timePeriods as ( -- sort time frames according to startdate per task
 select
  id, task, startDate, endDate,
  ROW_NUMBER() over (partition by task order by startDate, endDate) as rn
 from TaskPeriods
), cte as ( -- SQL recursive CTE expression
 select -- anchor query
  id, task, startDate, endDate, rn, 1 as GroupId
 from timePeriods
 where rn = 1

 union all

 select -- recursive sql query
  p2.id,
  p1.task,
  case
  when (p1.startDate between p2.startDate and p2.endDate) then p2.startDate
  when (p2.startDate between p1.startDate and p1.endDate) then p1.startDate
  when (p1.startDate < p2.startDate and p1.endDate > p2.endDate) then p1.startDate
  when (p1.startDate > p2.startDate and p1.endDate < p2.endDate) then p2.startDate
  else p2.startDate
  end as startDate,

  case
  when (p1.endDate between p2.startDate and p2.endDate) then p2.endDate
  when (p2.endDate between p1.startDate and p1.endDate) then p1.endDate
  when (p1.startDate < p2.startDate and p1.endDate > p2.endDate) then p1.endDate
  when (p1.startDate > p2.startDate and p1.endDate < p2.endDate) then p2.endDate
  else p2.endDate
  end as endDate,

  p2.rn,
  case when
  (p1.startDate between p2.startDate and p2.endDate) or
  (p1.endDate between p2.startDate and p2.endDate) or
  (p1.startDate < p2.startDate and p1.endDate > p2.endDate) or
  (p1.startDate > p2.startDate and p1.endDate < p2.endDate)
  then
  p1.GroupId
  else
  (p1.GroupId+1)
  end as GroupId
 from cte p1 -- referencing CTE itself
 inner join timePeriods p2
  on p1.task = p2.task and
  (p1.rn+1) = p2.rn
)

select
 task, GroupId, min(startDate) startDate, max(endDate) endDate,
 string_agg(id,',') within group (order by id) as taskList
from cte
group by task, GroupId
order by task, GroupId