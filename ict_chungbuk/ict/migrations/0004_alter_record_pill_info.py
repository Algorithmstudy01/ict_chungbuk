# Generated by Django 4.2.15 on 2024-08-25 13:40

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('ict', '0003_record'),
    ]

    operations = [
        migrations.AlterField(
            model_name='record',
            name='pill_info',
            field=models.TextField(blank=True, null=True),
        ),
    ]
