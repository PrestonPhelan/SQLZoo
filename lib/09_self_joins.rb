# == Schema Information
#
# Table name: stops
#
#  id          :integer      not null, primary key
#  name        :string
#
# Table name: routes
#
#  num         :string       not null, primary key
#  company     :string       not null, primary key
#  pos         :integer      not null, primary key
#  stop_id     :integer

require_relative './sqlzoo.rb'

def num_stops
  # How many stops are in the database?
  execute(<<-SQL)
    SELECT
      COUNT(*)
    FROM
      stops
  SQL
end

def craiglockhart_id
  # Find the id value for the stop 'Craiglockhart'.
  execute(<<-SQL)
    SELECT
      id
    FROM
      stops
    WHERE
      name = 'Craiglockhart'
  SQL
end

def lrt_stops
  # Give the id and the name for the stops on the '4' 'LRT' service.
  execute(<<-SQL)
    SELECT
      stop_id, stops.name
    FROM
      routes
    JOIN
      stops ON routes.stop_id = stops.id
    WHERE
      num = '4' AND company = 'LRT'
  SQL
end

def connecting_routes
  # Consider the following query:
  #
  # SELECT
  #   company,
  #   num,
  #   COUNT(*)
  # FROM
  #   routes
  # WHERE
  #   stop_id = 149 OR stop_id = 53
  # GROUP BY
  #   company, num
  #
  # The query gives the number of routes that visit either London Road
  # (149) or Craiglockhart (53). Run the query and notice the two services
  # that link these stops have a count of 2. Add a HAVING clause to restrict
  # the output to these two routes.
  execute(<<-SQL)
    SELECT
     company,
     num,
     COUNT(*)
    FROM
     routes
    WHERE
     stop_id = 149 OR stop_id = 53
    GROUP BY
     company, num
    HAVING
      COUNT(*) > 1
  SQL
end

def cl_to_lr
  # Consider the query:
  #
  # SELECT
  #   a.company,
  #   a.num,
  #   a.stop_id,
  #   b.stop_id
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # WHERE
  #   a.stop_id = 53
  #
  # Observe that b.stop_id gives all the places you can get to from
  # Craiglockhart, without changing routes. Change the query so that it
  # shows the services from Craiglockhart to London Road.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      a.stop_id,
      b.stop_id
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    WHERE
      a.stop_id = 53 AND b.stop_id = 149
  SQL
end

def cl_to_lr_by_name
  # Consider the query:
  # #
  # SELECT
  #   a.company,
  #   a.num,
  #   stopa.name,
  #   stopb.name
  # FROM
  #   routes a
  # JOIN
  #   routes b ON (a.company = b.company AND a.num = b.num)
  # JOIN
  #   stops stopa ON (a.stop_id = stopa.id)
  # JOIN
  #   stops stopb ON (b.stop_id = stopb.id)
  # WHERE
  #   stopa.name = 'Craiglockhart'
  #
  # The query shown is similar to the previous one, however by joining two
  # copies of the stops table we can refer to stops by name rather than by
  # number. Change the query so that the services between 'Craiglockhart' and
  # 'London Road' are shown.
  execute(<<-SQL)
    SELECT
      a.company,
      a.num,
      stopa.name,
      stopb.name
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name = 'Craiglockhart' AND stopb.name = 'London Road'
  SQL
end

def haymarket_and_leith
  # Give the company and num of the services that connect stops
  # 115 and 137 ('Haymarket' and 'Leith')
  execute(<<-SQL)
    SELECT
      DISTINCT a.company,
      a.num
    FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    WHERE
      a.stop_id = 115 AND b.stop_id = 137
  SQL
end

def craiglockhart_and_tollcross
  # Give the company and num of the services that connect stops
  # 'Craiglockhart' and 'Tollcross'
  execute(<<-SQL)
    SELECT DISTINCT
      a.company,
      a.num
      FROM
      routes a
    JOIN
      routes b ON (a.company = b.company AND a.num = b.num)
    JOIN
      stops stopa ON (a.stop_id = stopa.id)
    JOIN
      stops stopb ON (b.stop_id = stopb.id)
    WHERE
      stopa.name = 'Craiglockhart' AND stopb.name = 'Tollcross'
  SQL
end

def start_at_craiglockhart
  # Give a distinct list of the stops that can be reached from 'Craiglockhart'
  # by taking one bus, including 'Craiglockhart' itself. Include the stop name,
  # as well as the company and bus no. of the relevant service.
  execute(<<-SQL)
    SELECT DISTINCT
      other_stops.name, other_routes.company, other_routes.num
    FROM
      stops craiglockhart
    JOIN
      routes craiglockhart_routes ON craiglockhart.id = craiglockhart_routes.stop_id
    JOIN
      routes other_routes ON craiglockhart_routes.num = other_routes.num AND craiglockhart_routes.company = other_routes.company
    JOIN
      stops other_stops ON other_routes.stop_id = other_stops.id
    WHERE
      craiglockhart.name = 'Craiglockhart'
  SQL
end

def craiglockhart_to_sighthill
  # Find the routes involving two buses that can go from Craiglockhart to
  # Sighthill. Show the bus no. and company for the first bus, the name of the
  # stop for the transfer, and the bus no. and company for the second bus.
  execute(<<-SQL)
    SELECT DISTINCT
      first_bus.num, first_bus.company, transfer_stops.name, second_bus.num, second_bus.company
    FROM
      stops craiglockhart
    JOIN
      routes craiglockhart_routes ON craiglockhart.id = craiglockhart_routes.stop_id
    JOIN
      routes first_bus ON craiglockhart_routes.num = first_bus.num AND craiglockhart_routes.company = first_bus.company
    JOIN
      stops transfer_stops ON first_bus.stop_id = transfer_stops.id
    JOIN
      routes second_bus ON transfer_stops.id = second_bus.stop_id
    JOIN
      routes sighthill_routes ON sighthill_routes.num = second_bus.num AND sighthill_routes.company = second_bus.company
    JOIN
      stops sighthill ON sighthill.id = sighthill_routes.stop_id
    WHERE
      craiglockhart.name = 'Craiglockhart' AND sighthill.name = 'Sighthill'
  SQL
end
