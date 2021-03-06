-- Users who have closed a ticket
-- XXX TODO: Merged users aren't treated as such
SELECT
    u.Name as Username,
    count(distinct t.id) as Tickets_resolved,
    count(distinct CASE WHEN txn.Created > (NOW() - interval 30 day) THEN t.id END) as Tickets_resolved_in_last_30_days
    FROM Users u
    JOIN Transactions txn
        ON txn.Creator = u.id
    JOIN Tickets t
        ON t.id = txn.ObjectId
       AND txn.ObjectType = 'RT::Ticket'
    JOIN Principals p
        ON p.id = u.id
    JOIN CachedGroupMembers cgm
        ON cgm.MemberId = p.id
    WHERE
           txn.Field = 'Status'
       AND txn.NewValue = 'resolved'
       AND t.Status != 'deleted'
       AND t.Type = 'ticket'
       AND t.EffectiveId = t.id
       AND p.Disabled = 0
       AND cgm.GroupId = 4
    GROUP BY u.Name
    ORDER BY u.Name;
