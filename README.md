# MBA - mise en place d'une infrstructure sécurisée

## 1. AWS (région UE Paris)

### Création d’un compartiments S3:

- Aller sur AWS au lien https://console.aws.amazon.com/console/home?region=us-east-1#
- Cliquez dans ’Services’ dans la navbar
- Tapez ’S3’ et sélectionnez ’S3 Stockage évolutif dans le cloud’

Vous arrivez dans les Compartiments S3,

- Cliquez sur le bouton ‘Créer un compartiment’
- Donnez un ’Nom du compartiment’ comme exemple ‘mds-2018’
- Sélectionnez la région ‘UE (Paris)’, impérativement en Europe
- Ne touchez pas au bouton 'Copier les paramètres d'un compartiment existant’
- Cliquez directement sur le bouton ’suivant’
- Cliquez directement sur suivant sans modifier les champs
- Cliquez sur ‘bloquer tout l’accès public’
- Cliquez sur le bouton ’Suivant’

Vous arrivez sur un récapitulatif des précédentes étapes, 

- Cliquez sur le bouton ’Suivant’

	ETAPE FINI.


### Ajout d’un user AWS:

- Aller sur AWS au lien https://console.aws.amazon.com/console/home?region=us-east-1#
- Cliquez dans ’Services’ dans la navbar
- Tapez ’IAM’ et sélectionnez ’Gérer les accès utilisateur et les clé de chiffrement’

Dans le tableau de bord a gauche,

- Cliquez sur ‘Utilisateurs’
- Cliquez sur le bouton ‘ajouter un utilisateur’
- Saisissez un nom d’utilisateur
- Cochez les deux cases ‘Accès par programmation’ et ‘Accès à AWS Management Console’

Un récapitulatif s'ouvre.

- Cliquez sur le bouton ’Suivant: Autorisations’ sans rien modifier
- Dans ‘définir des autorisations’, cliquez sur ‘Attachez directement les stratégies existantes’
- Dans le tableau, cochez ‘AdministratorAccess’
- Cliquez sur le bouton ’Suivant: Balises’
- Cliquez sur le bouton ’Suivant: Vérification’ dans rien entrer dans les champs
Vous arrivez sur un récapitulatif,
- Cliquez sur ‘Créer un utilisateur’
- Cliquez sur le bouton, "Téléchargez.csv" (mettez le csv de coté)

FINAL, votre utilisateur est maintenant crée.

Cliquez sur le bouton ‘Fermer'

	ETAPE FINI.





## 2. Packer 1.4.0 & Terraform 0.11.14 (prérequis)

### Récupération du projet git

https://github.com/ArnaudBnd/secu-MBA.git

### Key access - secret et execution

- Dans le fichier nommé .env, remplacer avec les clefs provenant du csv les variables suivantes:
    - AWS_ACCESS_KEY= votre clé access
    - AWS_SECRET_KEY= votre clé secret

```
# /live/region/eu-west-3/database/

source chemin-jusqu'au-fichier-.env
```

Exemple: source /Users/benede.a/Documents/secu-MBA/.env

### Génération de clé ssh

```
# /live/region/eu-west-3/database/

cd ~/.ssh/
ssh-keygen (Enter file in which to save the key: amazon_pub)
ssh-add -K ~/.ssh/amazon_pub
```

### Installation packer & terraform

```
brew install packer
brew install terraform
```

### Récupération de la configuration

```
# /live/region/eu-west-3/database/
# /live/region/eu-west-3/bastion/

terraform init
```

### Apply de la configuration bastion

```
# /live/region/eu-west-3/bastion/

terraform apply
```

Rentrez les informations necessaires comme:
Aller sur AWS au lien https://console.aws.amazon.com/console/home?region=us-east-1#
- ami_d (AWS->Services->EC2->AMI->ID d'AMI) 
- ami_key_pair_name (amazon_pub)
- ami_name (AWS->Services->EC2->AMI->Nom d'AMI)

### Apply de la configuration database

```
# /live/region/eu-west-3/database/

terraform apply
```

Rentrez les informations necessaires comme:
Aller sur AWS au lien https://console.aws.amazon.com/console/home?region=us-east-1#
- ami_d (AWS->Services->EC2->AMI->ID d'AMI) 
- ami_key_pair_name (amazon_pub)
- ami_name (AWS->Services->EC2->AMI->Nom d'AMI)

