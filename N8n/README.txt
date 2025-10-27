To deploy locally in docker, copy to a machine with docker installed, edit .env if you want, secure cookie set to false,
this allows you to use n8n without requiring tls certificates. This will set up a database and volumes for you.
Simply move into the n8n folder and run "sudo docker compose up -d". This will pull and set up the images. Once it is finished, 
visit http://localhost:5678/ to set up your n8n (: