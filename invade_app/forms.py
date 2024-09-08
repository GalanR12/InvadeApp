from django import forms

class InvadeForm(forms.Form):
    name = forms.CharField(max_length=30)
    date = forms.DateField()
    successfull = forms.RadioSelect()
    not_successfull = forms.RadioSelect()
    draw = forms.RadioSelect()