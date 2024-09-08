from django.db import models
from django.core.validators import MaxValueValidator, MinValueValidator, MinLengthValidator

class InvadeValue(models.Model):
    invade_id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=30)
    date = models.DateField()
    successfull = models.BooleanField(default=True)
    not_successfull = models.BooleanField(default=False)
    draw = models.BooleanField(default=False)


