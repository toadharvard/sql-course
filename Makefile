pet:
	@docker compose -f docker-compose-pet.yaml down
	docker compose -f docker-compose-pet.yaml up --force-recreate

milk:
	@docker compose -f docker-compose-milk.yaml down
	docker compose -f docker-compose-milk.yaml up --force-recreate
