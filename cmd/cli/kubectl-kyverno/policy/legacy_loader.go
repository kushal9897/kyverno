package policy

import yamlutils "github.com/kyverno/kyverno/pkg/utils/yaml"

func legacyLoader(_ string, content []byte) (*LoaderResults, error) {
	policies, vaps, bindings, vps, ivps, maps, err := yamlutils.GetPolicy(content)
	if err != nil {
		return nil, err
	}
	return &LoaderResults{
		Policies:                policies,
		VAPs:                    vaps,
		VAPBindings:             bindings,
		MAPs:                    maps,
		ValidatingPolicies:      vps,
		ImageValidatingPolicies: ivps,
	}, nil
}
