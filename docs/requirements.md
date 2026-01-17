# online museum

#################

## current

* Joomla 4.4
* MySQL
* PHP 8.3
* hosted by wartenberg on alfahosting.de ?
* ca 900 images / joomla only allow images <= 1 MB
* external: excel and web drive to manage fotos
* upgrade to joomla 5 or 6 by agentur:  https://sketch.media

## new

management of images, videos and pdfs, creating pages or Blog Posts

### features
* Porject name: Exhiby
* Testurl: museum-wartenberg.de (Hosteurope)

* uploading images and add tags, description ...
* duplicate detection e.g. https://github.com/libvips/ruby-vips  https://claude.ai/chat/92ce96df-20b4-4b15-8471-b046b1c7b1b2
* AI tagging (AWS Rekognition)
* collections and albums
* static pages like impressum of https://www.onlinemuseum-wartenberg.de/team
* Pages and Blog entries
* Künstler pages

* Foto of the day (instagram and FB too ?)
* release process of images
* Search (finds images)
* Guest Access to upload fotos with info

* QR Code for page (Hausnamen Schild + QR an Haus wie in langenpreising)
* user friendly url
* Logging of changes
* Responsive design: adjust to mobile devices (bootstrap of vanilla css)
* Accessibility
* extracting the current style and images
* rich text editor lexxy vs trix https://blog.saeloun.com/2025/10/14/lexxy-editor/

#### later stage

* error logging via rollbar
* monitoring via newrelic
* logging via papertrail


#### server monitoring

https://fulghum.io/self-hosting via AI

* https://github.com/nicolargo/glances

### project managment

* github with issues and board
* setup a clode development

### seed data

* where do i get a bunch of free images
####

### open question

* Assests where ? (Server, S3, Cloundinary or https://www.hetzner.com/de/cloud/)
* Hosting (netcup or https://www.hetzner.com/de/cloud/ )
* Staging System for testing?
* multi language (english)



############################################################################

# Hosting Considerations for Rails Image Management System

## Infrastructure & Deployment

- **Server size**: Start small (2GB RAM is often enough for Rails + processing), scale as needed. Image processing can be CPU/memory intensive.
- **Separate web and worker servers**: Put Sidekiq workers on different instances from your web server so heavy image processing doesn't block user requests.
- **Database backups**: Automate daily backups of PostgreSQL—this is critical since it holds all your metadata.
- **Monitoring & logging**: Use tools like New Relic, Datadog, or open-source alternatives (Grafana, Prometheus) to catch issues before users do.

## Image Processing & Performance

- **Processing limits**: Set reasonable timeouts for image operations. Large files or complex processing can crash workers.
- **Queue management**: Monitor Sidekiq queue lengths—if they pile up, you need more workers or faster processing.
- **CDN for delivery**: Serve images through a CDN (Cloudflare, CloudFront, etc.) to reduce latency globally. Users in Germany will get much faster delivery.
- **Caching**: Cache processed images (thumbnails, resized versions) aggressively so you don't reprocess the same image repeatedly.

## Security

- **File type validation**: Only allow specific formats (JPEG, PNG, WebP, etc.). Don't trust user input.
- **Scan for malware**: Consider virus scanning uploaded files, especially if users can share images publicly.
- **Rate limiting**: Prevent abuse (upload quotas per user, request limits).
- **Access control**: Ensure users can only access their own images. Implement proper authorization checks.
- **SSL/TLS**: Always use HTTPS. Let's Encrypt is free.
- **Secrets management**: Never hardcode AWS keys. Use environment variables or a secrets vault.

## Storage & Costs

- **Monitor storage usage**: Track how much you're spending on cloud storage. Implement cleanup policies (delete old unused images after N days).
- **Retention policies**: Should deleted images be permanently removed or kept in archive?
- **Egress costs**: Downloading/serving images from the cloud can be expensive. Budget for this.
- **Versioning**: Decide if you need to keep image history or just the latest version.

## Database Considerations

- **Connection pooling**: Rail's default might not be enough under load. Use PgBouncer.
- **Indexing**: Add database indexes on frequently queried fields (user_id, created_at, etc.).
- **Query optimization**: Monitor slow queries and optimize N+1 problems.
- **Disk space**: Images are stored remotely, but metadata grows—monitor your database disk.

## User Experience & Reliability

- **Error handling**: Gracefully handle failed uploads or processing. Don't leave users hanging.
- **Retry logic**: Failed background jobs should retry with exponential backoff.
- **Status updates**: Show users real-time upload/processing progress where possible.
- **Downtime strategy**: Plan for maintenance windows. Use read replicas if needed for zero-downtime deployments.

## Scaling Preparation

- **Database replication**: Plan for read replicas if you get heavy traffic.
- **Horizontal scaling**: Use load balancing (nginx, HAProxy) so you can add more web servers.
- **Caching layers**: Redis for session storage and query caching.
- **API rate limiting**: Prevent one user from hammering your API.

## Compliance & Legal (EU/Germany specific)

- **GDPR**: Right to deletion, data portability, privacy policy, user consent for tracking.
- **Data residency**: If storing in EU, ensure it stays in EU (relevant for DigitalOcean Frankfurt or Hetzner).
- **Terms of Service**: Define acceptable use, liability limits, data retention policies.
- **User data export**: Build features to let users download/export their data.

## Operations

- **Automated testing**: Unit, integration, and end-to-end tests catch regressions.
- **Staging environment**: Test deployments on staging before production.
- **Documentation**: Document deployment process, troubleshooting, and runbooks.
- **Alerting**: Set up alerts for disk space, queue delays, error rates, server down.

## Cost Optimization

- **Reserved instances**: If on cloud providers, use reserved pricing for baseline capacity.
- **Auto-scaling**: Scale down during off-peak hours.
- **Image formats**: Serve WebP to modern browsers (smaller file sizes).
- **Compression**: Aggressively compress images without losing quality.

## Start Simple, Add Complexity Later

Begin with a single server, managed database, DigitalOcean Spaces, and basic monitoring. As you grow, add workers, caching, CDN, and read replicas. Don't over-engineer from day one.
