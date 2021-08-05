
create view percentpopulation_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as numeric)) over (partition by dea.location order by dea.location, dea.date) as Rolling_people_vaccinated
from portfolioprojects..['coviddeaths'] dea
join portfolioprojects..['covidvaccinations'] vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


select *
from percentpopulation_vaccinated
