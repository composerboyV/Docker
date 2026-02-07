up:
	@echo "Creating necessary directories..."
	@mkdir -p /home/junkwak/data/mariadb /home/junkwak/data/wordpress
	@sudo chown $(USER):$(USER) /home/junkwak/data/mariadb /home/junkwak/data/wordpress
	@echo "Building images..."
	@cd ./srcs && docker compose build
	@echo "Starting services..."
	@cd ./srcs && docker compose up -d
	@echo "Services started successfully!"

down:
	@echo "Stopping services..."
	@cd ./srcs && docker compose down
	@echo "Services stopped."

clean:
	@echo "Stopping and removing all containers, networks, and images..."
	@cd ./srcs && docker compose down -v --rmi all 2>/dev/null || true
	@docker system prune -af
	@docker volume prune -f
	@sudo rm -rf /home/junkwak/data/mariadb/* /home/junkwak/data/wordpress/* 2>/dev/null || true
	@echo "Cleanup completed."

restart:
	@echo "Restarting services..."
	@cd ./srcs && docker compose restart
	@echo "Services restarted."

logs:
	@cd ./srcs && docker compose logs -f

status:
	@cd ./srcs && docker compose ps

rebuild:
	@echo "Rebuilding and restarting services..."
	@cd ./srcs && docker compose down
	@cd ./srcs && docker compose build --no-cache
	@cd ./srcs && docker compose up -d
	@echo "Rebuild completed."

.PHONY: up down clean restart logs status rebuild