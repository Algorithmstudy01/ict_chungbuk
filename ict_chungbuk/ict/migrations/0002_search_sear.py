# Generated by Django 4.2.15 on 2024-08-25 13:18

from django.db import migrations, models
import django.db.models.deletion


class Migration(migrations.Migration):

    dependencies = [
        ('ict', '0001_initial'),
    ]

    operations = [
        migrations.CreateModel(
            name='Search',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('pill_info', models.TextField()),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='ict.userlist')),
            ],
        ),
        migrations.CreateModel(
            name='Sear',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('pill_code', models.CharField(max_length=255)),
                ('pill_name', models.CharField(max_length=255)),
                ('confidence', models.CharField(max_length=255)),
                ('efficacy', models.TextField()),
                ('manufacturer', models.CharField(max_length=255)),
                ('usage', models.TextField()),
                ('precautions_before_use', models.TextField()),
                ('usage_precautions', models.TextField()),
                ('drug_food_interactions', models.TextField()),
                ('side_effects', models.TextField()),
                ('storage_instructions', models.TextField()),
                ('pill_image', models.TextField()),
                ('pill_info', models.TextField()),
                ('created_at', models.DateTimeField(auto_now_add=True)),
                ('user', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='ict.userlist')),
            ],
        ),
    ]
