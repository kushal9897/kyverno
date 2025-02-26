package admissionpolicy

import (
	admissionregistrationv1 "k8s.io/api/admissionregistration/v1"
	"k8s.io/apimachinery/pkg/api/meta"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/labels"
	"k8s.io/apimachinery/pkg/runtime"
	"k8s.io/apiserver/pkg/admission"
	"k8s.io/apiserver/pkg/admission/plugin/webhook/predicates/rules"
)

// matches checks the following:
// - if the namespace selector matches the resource namespace
// - if the object selector matches the resource
// - if the resource is excluded by the policy/binding
// - if the resource matches the policy/binding rules
func matches(attr admission.Attributes, namespaceSelectorMap map[string]map[string]string, matchCriteria admissionregistrationv1.MatchResources) (bool, error) {
	// check if the namespace selector matches the resource namespace
	if matchCriteria.NamespaceSelector != nil {
		if len(matchCriteria.NamespaceSelector.MatchLabels) > 0 || len(matchCriteria.NamespaceSelector.MatchExpressions) > 0 {
			selector, err := metav1.LabelSelectorAsSelector(matchCriteria.NamespaceSelector)
			if err != nil {
				return false, err
			}
			if nsLabels, ok := namespaceSelectorMap[attr.GetNamespace()]; ok {
				if !selector.Matches(labels.Set(nsLabels)) {
					return false, nil
				}
			} else {
				return false, nil
			}
		}
	}

	// check if the object selector matches the resource
	if matchCriteria.ObjectSelector != nil {
		if len(matchCriteria.ObjectSelector.MatchLabels) > 0 || len(matchCriteria.ObjectSelector.MatchExpressions) > 0 {
			selector, err := metav1.LabelSelectorAsSelector(matchCriteria.ObjectSelector)
			if err != nil {
				return false, err
			}
			if !matchObject(attr.GetObject(), selector) && !matchObject(attr.GetOldObject(), selector) {
				return false, nil
			}
		}
	}

	// check if the resource is excluded by the policy/binding
	if len(matchCriteria.ExcludeResourceRules) != 0 {
		if matchesResourceRules(matchCriteria.ExcludeResourceRules, attr) {
			return false, nil
		}
	}

	// check if the resource is matched by the policy/binding
	if len(matchCriteria.ResourceRules) != 0 {
		return matchesResourceRules(matchCriteria.ResourceRules, attr), nil
	}

	return true, nil
}

func matchObject(obj runtime.Object, selector labels.Selector) bool {
	if obj == nil {
		return false
	}
	accessor, err := meta.Accessor(obj)
	if err != nil {
		return false
	}
	return selector.Matches(labels.Set(accessor.GetLabels()))
}

func matchesResourceRules(resourceRules []admissionregistrationv1.NamedRuleWithOperations, attr admission.Attributes) bool {
	for _, r := range resourceRules {
		ruleMatcher := rules.Matcher{
			Rule: r.RuleWithOperations,
			Attr: attr,
		}
		if !ruleMatcher.Matches() {
			continue
		}
		// an empty name list always matches
		if len(r.ResourceNames) == 0 {
			return true
		}

		name := attr.GetName()
		for _, matchedName := range r.ResourceNames {
			if name == matchedName {
				return true
			}
		}
	}
	return false
}
